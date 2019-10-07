local slo = import '../slo-libsonnet/slo.libsonnet';

{
  local latencybudget = slo.latencybudget({
    metric: 'prometheus_http_request_duration_seconds',
    selectors: ['namespace="default"', 'job="fooapp"'],
  }),

  // Output these as example
  recordingrules: latencybudget.recordingrules,
}
