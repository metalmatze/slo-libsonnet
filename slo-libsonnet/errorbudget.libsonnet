local util = import '_util.libsonnet';

{
  errorbudget(param):: {
    local slo = {
      metric: error 'must set metric for errorburn',
      selectors: error 'must set selectors for errorburn',
      slidingWindow: '30d',
      errorBudget: error 'must set errorBudget for errorburn',
      errorBudgetMetric: self.metric + '_errorbudget',
      labels: [],
      codeSelector: 'code',
    } + param,

    local labels =
      util.selectorsToLabels(slo.selectors) +
      util.selectorsToLabels(slo.labels),

    local requestsTotal = {
      record: 'status_class:%s:increase%s' % [slo.metric, slo.slidingWindow],
      expr: |||
        sum(label_replace(increase(%s{%s}[%s]), "status_class", "${1}xx", "%s", "([0-9])..")) by (status_class)
      ||| % [
        slo.metric,
        std.join(',', slo.selectors),
        slo.slidingWindow,
        slo.codeSelector,
      ],
      labels: labels,
    },

    local errorBudgetRequests = {
      record: '%s_requests' % slo.errorBudgetMetric,
      expr: |||
        (
          %f
        *
          sum(%s{%s})
        )
      ||| % [
        slo.errorBudget,
        requestsTotal.record,
        std.join(',', slo.selectors),
      ],
      labels: labels {
        window: slo.slidingWindow,
      },
    },

    local errorBudgetRemaining = {
      record: '%s_remaining' % slo.errorBudgetMetric,
      expr: |||
        (
          sum(%s{%s})
        -
          sum(%s{%s})
        )
      ||| % [
        errorBudgetRequests.record,
        std.join(',', slo.selectors),
        requestsTotal.record,
        std.join(',', slo.selectors + ['status_class="5xx"']),
      ],
      labels: labels {
        window: slo.slidingWindow,
      },
    },

    local errorBudget = {
      record: slo.errorBudgetMetric,
      expr: |||
        (
          %s
        /
          %s
        )
      ||| % [
        errorBudgetRemaining.record,
        errorBudgetRequests.record,
      ],
      labels: labels {
        window: slo.slidingWindow,
      },
    },

    recordingrules: [
      requestsTotal,
      errorBudgetRequests,
      errorBudgetRemaining,
      errorBudget,
    ],
  },
}
