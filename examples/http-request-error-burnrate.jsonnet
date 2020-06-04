local slo = import '../slo-libsonnet/slo.libsonnet';

{
  local errorburnrate = slo.errorburn({
    alertName: 'ErrorBudgetBurn',
    // This metric probably doesn't make a lot of sense.
    // However, it is availabe on every Prometheus by default.
    metric: 'promhttp_metric_handler_requests_total',
    selectors: ['namespace="default"', 'job="fooapp"'],
    target: 0.999,  // 99.9%
  }),

  // Output these as example
  recordingrule: errorburnrate.recordingrules,
  alerts: errorburnrate.alerts,
}
