local slo = import '../slo-libsonnet/slo.libsonnet';

{
  local latency = slo.latency({
    metric: 'prometheus_http_request_duration_seconds',
    selectors: ['namespace="default"', 'job="fooapp"'],
    quantile: 0.99,

    warning: 0.500,  // 500ms
    critical: 1.0,  // 1s
  }),

  // Output these as example
  recordingrule: latency.recordingrule(),
  alerts: [
    latency.alertWarning,
    latency.alertCritical,
  ],

  grafana: {
    gauge: std.toString(latency.grafana.gauge),
    graph: std.toString(latency.grafana.graph),
  },
}
