local slo = import '../slo-libsonnet/slo.libsonnet';

{
  local latency = slo.latency({
    metric: 'prometheus_http_request_duration_seconds',
    quantile: 0.99,

    warning: 0.500,  // 500ms
    critical: 1.0,  // 1s
    jobSelector: 'fooapp',
    namespaceSelector: 'default',
  }),

  // Output these as example
  recordingrule: latency.recordingrule,
  alerts: [
    latency.alertWarning,
    latency.alertCritical,
  ],

  gauge: latency.grafana.gauge,
}
