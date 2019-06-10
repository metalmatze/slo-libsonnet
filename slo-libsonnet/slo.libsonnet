{
  errors(slo):: {
    local recordingrule = {
      expr: 'sum(rate(%s{%s}[10m])) BY (code)' % [
        slo.metric,
        slo.selectors,
      ],
      record: 'code:%s:rate:sum' % slo.metric,
    },
    recordingrule: recordingrule,

    alertWarning: {
      expr: '%s{code!~"2.."} * 100 / %s > %s' % [recordingrule.record, recordingrule.record, slo.warning],
      'for': '5m',
      labels: {
        severity: 'warning',
      },
    },

    alertCritical: {
      expr: '%s{code!~"2.."} * 100 / %s > %s' % [recordingrule.record, recordingrule.record, slo.critical],
      'for': '5m',
      labels: {
        severity: 'critical',
      },
    },

    grafana: {
      gauge: {
        datasource: '$datasource',
        options: {
          maxValue: '1.5',  // TODO might need to be configurable
          minValue: 0,
          thresholds: [
            {
              color: 'green',
              index: 0,
              value: null,
            },
            {
              color: '#EAB839',
              index: 1,
              value: slo.warning,
            },
            {
              color: 'red',
              index: 2,
              value: slo.critical,
            },
          ],
          valueOptions: {
            decimals: null,
            stat: 'last',
            unit: 'dtdurations',
          },
        },
        targets: [
          {
            expr: '%s{quantile="%.2f"}' % [
              recordingrule.record,
              slo.quantile,
            ],
            format: 'time_series',
          },
        ],
        title: 'P99 Latency',
        type: 'gauge',
      },
    },
  },

  latency(slo):: {
    local recordingrule = {
      expr: 'histogram_quantile(%.2f, sum(rate(%s_bucket{%s%s}[5m])) by (le))' % [
        slo.quantile,
        slo.metric,
        slo.selectors,
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

    grafana: {
      gauge: {
        datasource: '$datasource',
        options: {
          maxValue: '1.5',  // TODO might need to be configurable
          minValue: 0,
          thresholds: [
            {
              color: 'green',
              index: 0,
              value: null,
            },
            {
              color: '#EAB839',
              index: 1,
              value: slo.warning,
            },
            {
              color: 'red',
              index: 2,
              value: slo.critical,
            },
          ],
          valueOptions: {
            decimals: null,
            stat: 'last',
            unit: 'dtdurations',
          },
        },
        targets: [
          {
            expr: '%s{quantile="%.2f"}' % [
              recordingrule.record,
              slo.quantile,
            ],
            format: 'time_series',
          },
        ],
        title: 'P99 Latency',
        type: 'gauge',
      },
    },
  },
}
