local slo = import '../slo-libsonnet/slo.libsonnet';

{
  local errorlatencyburn = slo.errorlatencyburn({
    alertName: 'ErrorBudgetBurn',
    // This metric probably doesn't make a lot of sense.
    // However, it is availabe on every Prometheus by default.
    metric: 'http_request_duration_seconds',
    selectors: ['namespace="default"', 'job="fooapp"'],
    target: 0.999,
  }),

  // Output these as example
  recordingrule: errorlatencyburn.recordingrules,
  alerts: errorlatencyburn.alerts,
}
