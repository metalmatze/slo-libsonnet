local slo = import '../slo-libsonnet/slo.libsonnet';

{
  local errorburnrate = slo.errorburn({
    // This metric probably doesn't make a lot of sense.
    // However, it is availabe on every Prometheus by default.
    metric: 'promhttp_metric_handler_requests_total',
    selectors: ['namespace="default"','job="fooapp"'],

    errorBudget: 1-0.999,
  }),

  // Output these as example
  recordingrule: errorburnrate.recordingrules,
  alerts: errorburnrate.alerts,
}
