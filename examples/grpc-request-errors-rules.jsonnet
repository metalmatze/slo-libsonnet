local slo = import '../slo-libsonnet/slo_grpc.libsonnet';

{
  local errors = slo.errors({
    metric: 'grpc_server_handled_total',
    selectors: 'grpc_type="unary",namespace="default",job="fooapp"',

    warning: 5,  // 5% of total requests
    critical: 10,  // 10% of total requests
  }),

  // Output these as example
  recordingrule: errors.recordingrule,
  alerts: [
    errors.alertWarning,
    errors.alertCritical,
  ],
}
