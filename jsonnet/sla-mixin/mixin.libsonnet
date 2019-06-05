{
  latency(slo):: {
    local recordingrule = {
      expr: 'histogram_quantile(%.2f, sum(rate(%s_bucket[5m])) by (le))' % [
        slo.quantile,
        slo.metric,
      ],
      record: '%s:histogram_quantile' % slo.metric,
      labels: {
        quantile: '%.2f' % slo.quantile,
      },
    },
    recordingrule: recordingrule,

    alertWarning: {
      expr: '%s > %.3f' % [recordingrule.record, slo.warning],
      'for': '5m',
      labels: {
        severity: 'warning',
      },
    },

    alertCritical: {
      expr: '%s > %.3f' % [recordingrule.record, slo.critical],
      'for': '5m',
      labels: {
        severity: 'critical',
      },
    },
  },
}
