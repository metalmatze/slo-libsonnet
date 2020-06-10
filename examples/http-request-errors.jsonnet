local slo = import '../slo-libsonnet/slo.libsonnet';

{
  local errors = slo.errors({
    metric: 'promhttp_metric_handler_requests_total',
    selectors: ['namespace="default"', 'job="fooapp"'],
    errorSelector: ['code=~"5.."'],

    warning: 0.05,  // 5% of total requests
    critical: 0.1,  // 10% of total requests
  }),

  // Output these as example
  alerts: errors.alerts,
  grafana: {
    graph: std.toString(errors.grafana.graph),
  },
}
