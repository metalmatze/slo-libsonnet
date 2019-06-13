local slo = import 'slo-libsonnet/slo.libsonnet';

local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local prometheus = grafana.prometheus;

// This mixin is meant to be consumed by other parts of your stack.
// As an example you can import this into the kube-prometheus stack,
// where the alerts, rules and dashboards will be integrated with the Kubernetes manifests.

{
  local latency = slo.latency({
    metric: 'prometheus_http_request_duration_seconds',
    selectors: 'namespace="monitoring",service="prometheus-metalmatze"',

    quantile: 0.99,
    warning: 0.500,  // 500ms
    critical: 1.0,  // 1ms
  }),

  local errors = slo.errors({
    metric: 'promhttp_metric_handler_requests_total',
    selectors: 'namespace="monitoring",service="prometheus-metalmatze"',

    warning: 5,  // %5
    critical: 10,  // 10%
  }),

  prometheusRules+:: {
    groups+: [
      {
        name: 'slo.rules',
        rules: [
          latency.recordingrule(quantile)
          for quantile in [0.50, 0.90, 0.99]
        ] + [
          errors.recordingrule,
        ],
      },
    ],
  },

  prometheusAlerts+:: {
    groups+: [
      {
        name: 'slo.alerts',
        rules: [
          latency.alertWarning {
            alert: 'PrometheuesHighLatency',
            'for': '1m',
            annotations: {
              message: 'The Prometheus server has a 99th percentile latency of {{ $value }} seconds.',
            },
          },
          latency.alertCritical {
            alert: 'PrometheuesHighLatency',
            'for': '1m',
            annotations: {
              message: 'The Prometheus server has a 99th percentile latency of {{ $value }} seconds.',
            },
          },
          errors.alertWarning {
            alert: 'PrometheusErrorsHigh',
            annotations: {
              message: 'Prometheus is returning errors for {{ $value }}% of requests.',
            },
          },
          errors.alertCritical {
            alert: 'PrometheusErrorsHigh',
            annotations: {
              message: 'Prometheus is returning errors for {{ $value }}% of requests.',
            },
          },
        ],
      },
    ],
  },

  grafanaDashboards+:: {
    'prometheus-slo.json':
      dashboard.new(
        'Prometheus SLOs',
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
      )
      .addRow(
        row.new()
        .addPanel(latency.grafana.gauge {
          span: 2,
        })
        .addPanel(latency.grafana.graph {
          span: 10,
        })
      )
      .addRow(
        row.new()
        .addPanel(errors.grafana.graph),
      ),
  },
}
