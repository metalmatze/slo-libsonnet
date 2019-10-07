{
  latencybudget(param):: {
    local slo = {
      metric: error 'must set metric for errorburn',
      selectors: error 'must set selectors for errorburn',
      errorBudget: error 'must set errorBudget for errorburn',
      statusCode: 'code',
    } + param,

    local labels = {
      [s[0]]: std.strReplace(s[1], '"', '')
      for s in [
        std.split(s, '=')
        for s in slo.selectors
      ]
    },

    local requestsTotal = {
      record: '%s:increase30d:sum' % slo.metric,
      expr: |||
        sum(increase(%s{%s}[30d]))
      ||| % [
        slo.metric + '_count',
        std.join(',', slo.selectors),
      ],
      labels: labels,
    },

    local requestsSlow = {
      record: 'slow:%s:increase30d:sum' % slo.metric,
      expr: |||
        sum(%s{%s}) - sum(increase(%s{%s}[30d]))
      ||| % [
        requestsTotal.record,
        std.join(',', slo.selectors),
        slo.metric + '_bucket',
        std.join(',', slo.selectors + ['le="0.5"']),
      ],
      labels: labels,
    },

    recordingrules: [
      requestsTotal,
      requestsSlow,
    ],
  },
}
