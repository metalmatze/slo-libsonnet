local latency = import '../slo-libsonnet/latency-burn.libsonnet';

{
  local query = latency.burn({
    metric: 'http_request_duration_seconds_bucket',
    selectors: ['job="telemeter-server"','handler="upload"'],

    latencyTheshold: 1, # How much responce delay is too much.
    latencyBudget: 100-99, # The 30 days SLO promise.
  }),

  // Output these as example
  recordingrule: query.recordingrules,
  alerts: query.alerts,
}
