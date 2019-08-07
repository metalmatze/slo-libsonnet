local slo = import '../slo-libsonnet/slo_grpc.libsonnet';

{
  local latency = slo.latency({
    metric: 'grpc_server_handling_seconds',
    selectors: 'grpc_type="unary",namespace="default",job="fooapp"',
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

  gauge: latency.grafana.gauge,
  graph: latency.grafana.graph,
}
