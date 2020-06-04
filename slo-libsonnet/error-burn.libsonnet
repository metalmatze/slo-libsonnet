local util = import '_util.libsonnet';
local errors = import 'errors.libsonnet';
{
  errorburn(param):: {
    local slo = {
      alertName: 'ErrorBudgetBurn',
      alertMessage: 'High error budget burn for %s (current value: {{ $value }})' % [std.strReplace(std.join(',', self.selectors), '"', '')],
      metric: error 'must set metric for error burn',
      recordingrule: '%s:burnrate%%s' % self.metric,  // double %% at the end as we template again further on
      selectors: [],
      errorSelectors: ['code=~"5.."'],
      target:
        if std.objectHas(param, 'errorBudget') then  // compatibility for a couple of months
          1 - param.errorBudget
        else
          error 'must set target for error burn',
      windows: [
        { severity: 'critical', 'for': '2m', long: '1h', short: '5m', factor: 14.4 },
        { severity: 'critical', 'for': '15m', long: '6h', short: '30m', factor: 6 },
        { severity: 'warning', 'for': '1h', long: '1d', short: '2h', factor: 3 },
        { severity: 'warning', 'for': '3h', long: '3d', short: '6h', factor: 1 },
      ],
    } + param,

    local labels = util.selectorsToLabels(slo.selectors),

    recordingrules: [
      {
        expr: |||
          sum(rate(%(metric)s{%(errorSelectors)s}[%(rate)s]))
          /
          sum(rate(%(metric)s{%(selectors)s}[%(rate)s]))
        ||| % {
          metric: slo.metric,
          selectors: std.join(',', slo.selectors),
          errorSelectors: std.join(',', slo.selectors + slo.errorSelectors),
          rate: rate,
        },
        record: slo.recordingrule % rate,
        labels: labels,
      }
      for rate in std.set([  // Get the unique array of short and long window rates
        r.short
        for r in slo.windows
      ] + [
        r.long
        for r in slo.windows
      ])
    ],

    alerts:
      [
        {
          alert: slo.alertName,
          expr: |||
            sum(%(recordingruleShort)s{%(selectors)s}) > (%(factor).2f * (1-%(target).5f))
            and
            sum(%(recordingruleLong)s{%(selectors)s}) > (%(factor).2f * (1-%(target).5f))
          ||| % {
            recordingruleShort: slo.recordingrule % w.short,
            recordingruleLong: slo.recordingrule % w.long,
            selectors: std.join(',', slo.selectors),
            target: slo.target,
            factor: w.factor,
          },
          labels: labels {
            severity: w.severity,
          },
          annotations: {
            message: slo.alertMessage,
          },
          'for': '%(for)s' % w,
        }
        for w in slo.windows
      ],
  },
}
