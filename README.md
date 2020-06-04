# SLO libsonnet

>NOTE: This project is in pre-alpha stage. Everything you see here may change significantly in the following updates

Generate Prometheus alerting & recording rules and Grafana dashboards for your SLOs.

## Alerts

### Error Percentage

[embedmd]:#(examples/http-request-errors.jsonnet)
```jsonnet
local slo = import '../slo-libsonnet/slo.libsonnet';

{
  local errors = slo.errors({
    metric: 'promhttp_metric_handler_requests_total',
    selectors: ['namespace="default"', 'job="fooapp"'],

    warning: 0.05,  // 5% of total requests
    critical: 0.1,  // 10% of total requests
  }),

  // Output these as example
  recordingrule: errors.recordingrule,
  alerts: [
    errors.alertWarning,
    errors.alertCritical,
  ],
  grafana: {
    graph: std.toString(errors.grafana.graph),
  },
}
```

### Latency Percentage

[embedmd]:#(examples/http-request-latency.jsonnet)
```jsonnet
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
```

### Multi Error Burn Rates

[embedmd]:#(examples/http-request-error-burnrate.jsonnet)
```jsonnet
local slo = import '../slo-libsonnet/slo.libsonnet';

{
  local errorburnrate = slo.errorburn({
    alertName: 'ErrorBudgetBurn',
    // This metric probably doesn't make a lot of sense.
    // However, it is availabe on every Prometheus by default.
    metric: 'promhttp_metric_handler_requests_total',
    selectors: ['namespace="default"', 'job="fooapp"'],

    errorBudget: 1 - 0.999,
  }),

  // Output these as example
  recordingrule: errorburnrate.recordingrules,
  alerts: errorburnrate.alerts,
}
```

### Multi Error Burn Rates on Latency

Having too many too slow requests is burning the error budget.
So, if over a given time range there are too many slow requests this will alert you.

[embedmd]:#(examples/http-request-latency-burnrate.jsonnet)
```jsonnet
local slo = import '../slo-libsonnet/slo.libsonnet';

{
  local query = slo.latencyburn({
    alertName: 'LatencyBudgetBurn',
    metric: 'http_request_duration_seconds',
    selectors: ['namespace="default"', 'job="fooapp"'],
    // How much responce delay is too much.
    latencyTarget: '1',
    // The 30 days SLO promise.
    // When the promise is 99% that means that
    // in 30d can only have 1% queries above the latencyTarget.
    latencyBudget: 1 - 0.99,
  }),

  // The actual output results.
  recordingrule: query.recordingrules,
  alerts: query.alerts,
}
```
