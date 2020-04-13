local util = import '_util.libsonnet';
{
  httpRates(param):: {
    local slo = {
      metric: error 'must set metric for httpRates',
      recordingRuleMetric: self.metric,
      selectors: error 'must set selectors for httpRates',
      labels: [],
      rates: ['5m', '30m', '1h', '2h', '6h', '1d', '3d'],
      codeSelector: 'code',
    } + param,

    local labels =
      util.selectorsToLabels(slo.selectors) +
      util.selectorsToLabels(slo.labels),

    rateRules: [
      {
        expr: |||
          sum by (status_class) (
            label_replace(
              rate(%s{%s}[%s]
            ), "status_class", "${1}xx", "%s", "([0-9])..")
          )
        ||| % [
          slo.metric,
          std.join(',', slo.selectors),
          rate,
          slo.codeSelector,
        ],
        record: 'status_class:%s:rate%s' % [
          slo.recordingRuleMetric,
          rate,
        ],
        labels: labels,
        rate:: rate,
      }
      for rate in std.uniq(slo.rates)
    ],

    errorRateRules: [
      {
        expr: |||
          sum(%s{%s})
          /
          sum(%s{%s})
        ||| % [
          r.record,
          std.join(',', slo.selectors + ['status_class="5xx"']),
          r.record,
          std.join(',', slo.selectors),
        ],
        record: 'status_class_5xx:%s:ratio_rate%s' % [
          slo.recordingRuleMetric,
          r.rate,
        ],
        labels: labels,
        rate:: r.rate,
      }
      for r in self.rateRules
    ],
  },
}
