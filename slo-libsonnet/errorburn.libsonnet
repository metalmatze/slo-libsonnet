local errors = import 'errors.libsonnet';

{
  errorburn(param):: {
    local slo = {
      metric: error 'must set metric for errorburn',
      selectors: error 'must set selectors for errorburn',
      errorBudget: error 'must set errorBudget for errorburn',
      statusCode: 'code',
    } + param,

    local rates = ['5m', '30m', '1h', '2h', '6h', '1d', '3d'],
    local labels = {
      [s[0]]: std.strReplace(s[1], '"', '')
      for s in [
        std.split(s, '=')
        for s in slo.selectors
      ]
    },

    local errorRates = [
      errors.errors({
        metric: slo.metric,
        selectors: slo.selectors,
        rate: rate,
        statusCode: slo.statusCode,
      }).recordingrule
      for rate in rates
    ],

    local errorPercentages = [
      {
        expr: |||
          sum(%s{%s})
          /
          sum(%s{%s})
        ||| % [
          err.record,
          std.join(',', slo.selectors + ['status_code="5xx"']),
          err.record,
          std.join(',', slo.selectors),
        ],
        record: 'errors:%s' % err.record,
        labels: labels,
      }
      for err in errorRates
    ],
    recordingrules: errorRates + errorPercentages,

    local multiBurnRate30d = [
      {
        alert: 'ErrorBudgetBurn',
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
          errorPercentages[2].record,
          std.join(',', slo.selectors),
          slo.errorBudget,
          errorPercentages[0].record,
          std.join(',', slo.selectors),
          slo.errorBudget,
          errorPercentages[4].record,
          std.join(',', slo.selectors),
          slo.errorBudget,
          errorPercentages[1].record,
          std.join(',', slo.selectors),
          slo.errorBudget,
        ],
        labels: labels {
          severity: 'critical',
          window: '30d',
        },
      },
    ],

    alerts: multiBurnRate30d,
  },
}
