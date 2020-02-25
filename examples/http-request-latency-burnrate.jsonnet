local latency = import '../slo-libsonnet/latency-burn.libsonnet';

{
  local query = latency.burn({
    metric: 'http_request_duration_seconds_bucket',
    selectors: ['job="telemeter-server"','handler="upload"'],
    # How much responce delay is too much.
    latencyTarget: "1",
    # The 30 days SLO promise.
    # When the promise is 99% that means that
    # in 30d can only have 1% quries above the latencyTarget.
    latencyBudget: 100-99,
  }),

  // The actual output results.
  recordingrule: query.recordingrules,
  alerts: query.alerts,
}
