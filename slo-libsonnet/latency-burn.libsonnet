local util = import '_util.libsonnet';
{
  local sumRule(param) = {
    local slo = {
      metric: error 'must set metric for sum recording',
      selectors: error 'must set selectors for sum recording',
      rate: error 'must set rate for sum recording',
    } + param,

    local labels =
      util.selectorsToLabels(slo.selectors),

    local recordingrule = {
      expr: |||
        sum(rate(%s{%s}[%s]))
      ||| % [
        slo.metric,
        std.join(',', slo.selectors),
        slo.rate,
      ],
      record: 'sum:%s:rate%s' % [
        slo.metric,
        slo.rate,
      ],
      labels: labels,
    },

    recordingrule: recordingrule,
  },


  burn(param):: {
    local slo = {
      metric: error 'must set metric for latency burn',
      selectors: error 'must set selectors for latency burn',
      latencyTheshold: error 'must set latencyTheshold latency burn',
      latencyBudget: error 'must set latencyBudget latency burn',
      labels: [],
    } + param,

    local rates = ['5m', '30m', '1h', '2h', '6h', '1d', '3d'],

    local labels =
      util.selectorsToLabels(slo.selectors),

    local latRates = [
      sumRule({
        metric: slo.metric,
        selectors: slo.selectors,
        rate: rate,
      }).recordingrule {
        // We need to communicate the rate to the errorPercentage step
        // They will be remove after that again
        labels+: { __tmpRate__: rate },
      }
      for rate in rates
    ],

    local latRule = [
      {
        # How many percent are above the SLO latency threshold.
        # First calculate how many requests are below the threshold and
        # substract those from 100 percent.
        # This gives the total requests that fail the SLO
        expr: |||
          1 - (
            %s{le="%s",code!~"5.."}
            /
            %s
          )
        ||| % [
          lat.record,
          slo.latencyTheshold,
          lat.record,
        ],
        record: 'latency:%s:ratio_rate%s' % [slo.metric, lat.labels.__tmpRate__],
        labels: labels,
      }
      for lat in latRates
    ],

    // Remove __tmpRate__ label from errorRates rules again
    local latRuleCleanedUp = std.map(
      function(rule) rule {
        local ls = super.labels,
        labels: {
          [k]: ls[k]
          for k in std.objectFields(ls)
          if !std.setMember(k, ['__tmpRate__'])
        },
      },
      latRates,
    ),

    recordingrules: latRuleCleanedUp + latRule,

    local multiBurnRate30d = [
      {
        alert: 'ErrorBudgetBurn',
        # Check how many procent are violating the SLO.
        # Send an alert only when this procent is above the burn rate.
        expr: |||
          (
            100 * %s > (14.4*%f)
            and
            100* %s > (14.4*%f)
          )
          or
          (
            100 * %s > (6*%f)
            and
            100 * %s > (6*%f)
          )
        ||| % [
          latRule[2].record,
          slo.latencyBudget,
          latRule[0].record,
          slo.latencyBudget,
          latRule[4].record,
          slo.latencyBudget,
          latRule[1].record,
          slo.latencyBudget,
        ],
        labels: labels {
          severity: 'critical',
        },
      },
      {
        alert: 'ErrorBudgetBurn',
        expr: |||
          (
            100 * %s > (3*%f)
            and
            100 * %s > (3*%f)
          )
          or
          (
            100 * %s > (%f)
            and
            100 * %s > (%f)
          )
        ||| % [
          latRule[5].record,
          slo.latencyBudget,
          latRule[3].record,
          slo.latencyBudget,
          latRule[6].record,
          slo.latencyBudget,
          latRule[4].record,
          slo.latencyBudget,
        ],
        labels: labels {
          severity: 'warning',
        },
      },
    ],

    alerts: multiBurnRate30d,
  },
}