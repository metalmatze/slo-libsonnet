local slo = import '../slo-libsonnet/slo.libsonnet';
local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local prometheus = grafana.prometheus;

local errors = slo.errors({
  metric: 'promhttp_metric_handler_requests_total',
  selectors: 'namespace="default",job="fooapp"',

  warning: 5,  // 5% of total requests
  critical: 10,  // 10% of total requests
});

dashboard.new(
  'Response Codes',
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
  .addPanel(errors.grafana.graph)
)
