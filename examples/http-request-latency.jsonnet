local slo = import '../jsonnet/sla-mixin/mixin.libsonnet';

{
  local latency = slo.latency({
    metric: 'prometheus_http_request_duration_seconds',
    quantile: 0.99,

    warning: 0.500,  // 500ms
    critical: 1.0,  // 1s
  }),

  // Output these as example
  recordingrule: latency.recordingrule,
  alerts: [
    latency.alertWarning,
    latency.alertCritical,
  ],

  gauge: latency.grafana.gauge,
}
