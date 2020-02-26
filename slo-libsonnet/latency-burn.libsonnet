local util = import '_util.libsonnet';
{
  burn(param):: {
    local slo = {
      metric: error 'must set metric for latency burn',
      selectors: error 'must set selectors for latency burn',
      latencyTarget: error 'must set latencyTarget latency burn',
      latencyBudget: error 'must set latencyBudget latency burn',
      labels: [],
    } + param,

    local rates = ['5m', '30m', '1h', '2h', '6h', '1d', '3d'],

    local labels =
      util.selectorsToLabels(slo.selectors),

    local latencyRules = [
      {
        # How many percent are above the SLO latency target.
        # First calculate how many requests are below the target and
        # substract those from 100 percent.
        # This gives the total requests that fail the SLO
        expr: |||
          1 - (
            sum(rate(%s{%s,le="%s",code!~"5.."}[%s]))
            /
            sum(rate(%s{%s}[%s]))
          )
        ||| % [
          slo.metric,
          std.join(',', slo.selectors),
          slo.latencyTarget,
          rate,
          slo.metric,
          std.join(',', slo.selectors),
          rate,
        ],
        record: 'latency:%s:ratio_rate%s' % [slo.metric, rate],
        labels: labels,
      }
      for rate in rates
    ],

    recordingrules: latencyRules,

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
          latencyRules[2].record,
          slo.latencyBudget,
          latencyRules[0].record,
          slo.latencyBudget,
          latencyRules[4].record,
          slo.latencyBudget,
          latencyRules[1].record,
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
          latencyRules[5].record,
          slo.latencyBudget,
          latencyRules[3].record,
          slo.latencyBudget,
          latencyRules[6].record,
          slo.latencyBudget,
          latencyRules[4].record,
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