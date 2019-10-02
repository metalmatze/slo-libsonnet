{
  errorbudget(param):: {
    local slo = {
      metric: 'http_requests_total',
      selectors: ['namespace="default"'],
      statusCode: 'code',
      errorBudget: 1 - 0.999,  // 99.9
    } + param,

    local labels = {
      [s[0]]: std.strReplace(s[1], '"', '')
      for s in [
        std.split(s, '=')
        for s in slo.selectors
      ]
    },

    local requestsTotal = {
      record: 'status_code:%s:increase30d:sum' % slo.metric,
      expr: |||
        sum(label_replace(increase(%s{%s}[30d]), "status_code", "${1}xx", "%s", "([0-9])..")) by (status_code)
      ||| % [
        slo.metric,
        std.join(',', slo.selectors),
        slo.statusCode,
      ],
      labels: labels,
    },

    local errorsTotal = {
      record: 'errors:%s' % requestsTotal.record,
      expr: |||
        %s{%s}
      ||| % [
        requestsTotal.record,
        std.join(',', slo.selectors + ['status_code="5xx"']),
      ],
      labels: labels,
    },

    local errorBudgetRequests = {
      record: 'errorbudget_requests:%s' % requestsTotal.record,
      expr: |||
        (%f) * sum(%s)
      ||| % [
        slo.errorBudget,
        requestsTotal.record,
      ],
      labels: labels,
    },

    local errorBudgetRemaining = {
      record: 'errorbudget_remaining:%s' % requestsTotal.record,
      expr: |||
        sum(%s{%s}) - sum(%s{%s})
      ||| % [
        errorBudgetRequests.record,
        std.join(',', slo.selectors),
        errorsTotal.record,
        std.join(',', slo.selectors),
      ],
      labels: labels,
    },

    local errorBudget = {
      record: 'errorbudget:%s' % requestsTotal.record,
      expr: |||
        %s / %s
      ||| % [
        errorBudgetRemaining.record,
        errorBudgetRequests.record,
      ],
      labels: labels,
    },

    recordingrules: [
      requestsTotal,
      errorsTotal,
      errorBudgetRequests,
      errorBudgetRemaining,
      errorBudget,
    ],
  },
}
