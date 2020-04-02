local util = import '_util.libsonnet';
{
  latencyburn(param):: {
    local slo = {
      alertName: 'LatencyBudgetBurn',
      metric: error 'must set metric for latency burn',
      selectors: error 'must set selectors for latency burn',
      latencyTarget: error 'must set latencyTarget latency burn',
      latencyBudget: error 'must set latencyBudget latency burn',
      labels: [],
      codeSelector: 'code',
    } + param,

    local rates = ['5m', '30m', '1h', '2h', '6h', '1d', '3d'],

    local rulesSelectors = slo.selectors + ['latency="' + slo.latencyTarget + '"'],

    local latencyRules = [
      {
        // How many percent are above the SLO latency target.
        // First calculate how many requests are below the target and
        // substract those from 100 percent.
        // This gives the total requests that fail the SLO
        expr: |||
          1 - (
            sum(rate(%s{%s,le="%s",%s!~"5.."}[%s]))
            /
            sum(rate(%s{%s}[%s]))
          )
        ||| % [
          slo.metric + '_bucket',
          std.join(',', slo.selectors),
          slo.latencyTarget,
          slo.codeSelector,
          rate,
          slo.metric + '_count',
          std.join(',', slo.selectors),
          rate,
        ],
        record: 'latencytarget:%s:rate%s' % [slo.metric, rate],
        labels: util.selectorsToLabels(rulesSelectors),
      }
      for rate in rates
    ],

    recordingrules: latencyRules,

    local multiBurnRate30d = [
      {
        alert: slo.alertName,
        // Check how many procent are violating the SLO.
        // Send an alert only when this procent is above the burn rate.
        expr: |||
          (
            %s{%s} > (14.4*%f)
            and
            %s{%s} > (14.4*%f)
          )
          or
          (
            %s{%s} > (6*%f)
            and
            %s{%s} > (6*%f)
          )
        ||| % [
          latencyRules[2].record,
          std.join(',', rulesSelectors),
          slo.latencyBudget,
          latencyRules[0].record,
          std.join(',', rulesSelectors),
          slo.latencyBudget,
          latencyRules[4].record,
          std.join(',', rulesSelectors),
          slo.latencyBudget,
          latencyRules[1].record,
          std.join(',', rulesSelectors),
          slo.latencyBudget,
        ],
        labels: util.selectorsToLabels(rulesSelectors) {
          severity: 'critical',
        },
        annotations: {
          message: 'High requests latency budget burn for %s (current value: {{ $value }})' % [std.strReplace(std.join(',', rulesSelectors), '"', '')],
        },
      },
      {
        alert: slo.alertName,
        expr: |||
          (
            %s{%s} > (3*%f)
            and
            %s{%s} > (3*%f)
          )
          or
          (
            %s{%s} > (%f)
            and
            %s{%s} > (%f)
          )
        ||| % [
          latencyRules[5].record,
          std.join(',', rulesSelectors),
          slo.latencyBudget,
          latencyRules[3].record,
          std.join(',', rulesSelectors),
          slo.latencyBudget,
          latencyRules[6].record,
          std.join(',', rulesSelectors),
          slo.latencyBudget,
          latencyRules[4].record,
          std.join(',', rulesSelectors),
          slo.latencyBudget,
        ],
        labels: util.selectorsToLabels(rulesSelectors) {
          severity: 'warning',
        },
        annotations: {
          message: 'High requests latency budget burn for %s (current value: {{ $value }})' % [std.strReplace(std.join(',', rulesSelectors), '"', '')],
        },
      },
    ],

    alerts: multiBurnRate30d,
  },
}
