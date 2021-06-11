local util = import '_util.libsonnet';
{
  latencyburn(param):: {
    local slo = {
      alertName: 'LatencyBudgetBurn',
      metric: error 'must set metric for latency burn',
      selectors: error 'must set selectors for latency burn',

      // Note, the latency target must be available as an exact histogram
      // bucket. As recording rules rely on it.
      latencyTarget: error 'must set latencyTarget latency burn',
      latencyBudget: error 'must set latencyBudget latency burn',
      alertLabels: {},
      alertAnnotations: {},
      codeSelector: 'code',
      notErrorSelector: '%s!~"5.."' % slo.codeSelector,
    } + param,

    local rates = ['5m', '30m', '1h', '2h', '6h', '1d', '3d'],

    local rulesSelectors = slo.selectors + ['latency="' + slo.latencyTarget + '"'],
    local alertSelectors = std.strReplace(std.join(',', rulesSelectors), '=~', '='),

    local latencyRules = [
      {
        // How many percent are above the SLO latency target.
        // First calculate how many requests are below the target and
        // substract those from 100 percent.
        // This gives the total requests that fail the SLO
        expr: |||
          1 - (
            sum(rate(%(bucketMetric)s{%(selectors)s,le="%(latencyTarget)s",%(notErrorSelector)s}[%(rate)s]))
            /
            sum(rate(%(countMetric)s{%(selectors)s}[%(rate)s]))
          )
        ||| % {
          bucketMetric: slo.metric + '_bucket',
          selectors: std.join(',', slo.selectors),
          latencyTarget: slo.latencyTarget,
          notErrorSelector: slo.notErrorSelector,
          rate: rate,
          countMetric: slo.metric + '_count',
        },
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
          alertSelectors,
          slo.latencyBudget,
          latencyRules[0].record,
          alertSelectors,
          slo.latencyBudget,
          latencyRules[4].record,
          alertSelectors,
          slo.latencyBudget,
          latencyRules[1].record,
          alertSelectors,
          slo.latencyBudget,
        ],
        labels: util.selectorsToLabels(rulesSelectors) {
          severity: 'critical',
        } + slo.alertLabels,
        annotations: {
          message: 'High requests latency budget burn for %s (current value: {{ $value }})' % [std.strReplace(std.join(',', rulesSelectors), '"', '')],
        } + slo.alertAnnotations,
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
          alertSelectors,
          slo.latencyBudget,
          latencyRules[3].record,
          alertSelectors,
          slo.latencyBudget,
          latencyRules[6].record,
          alertSelectors,
          slo.latencyBudget,
          latencyRules[4].record,
          alertSelectors,
          slo.latencyBudget,
        ],
        labels: util.selectorsToLabels(rulesSelectors) {
          severity: 'warning',
        } + slo.alertLabels,
        annotations: {
          message: 'High requests latency budget burn for %s (current value: {{ $value }})' % [std.strReplace(std.join(',', rulesSelectors), '"', '')],
        } + slo.alertAnnotations,
      },
    ],

    alerts: multiBurnRate30d,
  },
}
