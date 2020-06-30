local util = import '_util.libsonnet';

{
  errorlatencyburn(param):: {
    local slo = {
      alertName: 'ErrorBudgetBurn',
      alertMessage: 'App is burning too much error budget',
      metric: error 'must set metric for error burn',  // This has to be a histogram metric without _bucket or _count
      recordingrule: '%s:burnrate%%s' % self.metric,  // double %% at the end as we template again further on
      selectors: error 'must set selectors for error burn',
      target: error 'must set target for error burn',
      labels: [],
      codeSelector: 'code',
      windows: [
        { severity: 'critical', 'for': '2m', long: '1h', short: '5m', factor: 14.4 },
        { severity: 'critical', 'for': '15m', long: '6h', short: '30m', factor: 6 },
        { severity: 'warning', 'for': '1h', long: '1d', short: '2h', factor: 3 },
        { severity: 'warning', 'for': '3h', long: '3d', short: '6h', factor: 1 },
      ],
    } + param,

    local labels =
      util.selectorsToLabels(slo.selectors) +
      util.selectorsToLabels(slo.labels),

    recordingrules:
      [
        {
          record: slo.recordingrule % rate,
          expr: |||
            (
              (
                # sum of too slow requests
                sum(rate(%(metric)s_count{%(selectors)s,%(codeSelector)s!~"5.."}[%(rate)s]))
                -
                sum(rate(%(metric)s_bucket{%(selectors)s,%(codeSelector)s!~"5..",le="1"}[%(rate)s]))
              )
              +
              # sum of errors
              sum(rate(%(metric)s_count{%(selectors)s,%(codeSelector)s=~"5.."}[%(rate)s]))
            )
            /
            sum(rate(%(metric)s_count{%(selectors)s}[%(rate)s]))
          ||| % { selectors: std.join(',', slo.selectors), codeSelector: slo.codeSelector, metric: slo.metric, rate: rate },
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
            sum(%s) > (%.2f * %.5f)
            and
            sum(%s) > (%.2f * %.5f)
          ||| % [
            slo.recordingrule % w.long,
            w.factor,
            (1 - slo.target),
            slo.recordingrule % w.short,
            w.factor,
            (1 - slo.target),
          ],
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
