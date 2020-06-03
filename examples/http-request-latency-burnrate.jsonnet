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
