// Demonstrate sample application
local slo = import '../slo-libsonnet/slo.libsonnet';
local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local prometheus = grafana.prometheus;

{
  local appname = 'fooapp',
  // Defining reponse code SLO's
  local errors = slo.errors({
    metric: 'http_requests_total',  // Name of HTTP request counter metric, partitioned by code
    selectors: 'namespace="default",job="fooapp"',  // Selectors for specific application

    warning: 5,  // 5% of total requests
    critical: 10,  // 10% of total requests
    errorcodes: [400, 404, 500],  // List of codes that are considered against the error budget
  }),
  // Defining latency SLO's
  local latency = slo.latency({
    metric: 'http_request_duration_seconds',  // Metric name prefix for bucket
    selectors: 'namespace="default",job="fooapp"',  // Selectors for specific application
    quantile: 0.99,  // Rules will be generated for 99th Percentile
    warning: 0.500,  // 500ms
    critical: 1.0,  // 1s
  }),

  // Recording rules
  recordingrule: latency.recordingrule() + errors.recordingrule,

  // Alert rules
  alerts: [
    latency.alertWarning,
    latency.alertCritical,
    errors.alertWarning,
    errors.alertCritical,
  ],

  // Creating a new dashboard
  dashboard: dashboard.new(
    '%s' % appname,
    time_from='now-1h',
  ).addTemplate(
    {
      current: {
        text: 'Prometheus',
        value: 'Prometheus',
      },
      hide: 0,
      label: null,
      name: 'datasource',
      options: [],
      query: 'prometheus',
      refresh: 1,
      regex: '',
      type: 'datasource',
    },
  ).addRow(
    row.new()
    .addPanel(latency.grafana.gauge)
    .addPanel(latency.grafana.graph)
  ).addRow(
    row.new()
    .addPanel(errors.grafana.graph)
  ),
}
