{
  errors(slo):: {
    local recordingrule = {
      expr: |||
        sum(rate(%s{%s}[10m])) BY (code)
      ||| % [
        slo.metric,
        slo.selectors,
      ],
      record: 'code:%s:rate:sum' % slo.metric,
    },
    recordingrule: recordingrule,

    alertWarning: {
      expr: |||
        %s{code!~"2.."} * 100 / %s > %s
      ||| % [
        recordingrule.record,
        recordingrule.record,
        slo.warning,
      ],
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
    recordingrule(quantile=slo.quantile):: {
      expr: |||
        histogram_quantile(%.2f, sum(rate(%s_bucket{%s}[5m])) by (le))
      ||| % [
        quantile,
        slo.metric,
        slo.selectors,
      ],
      record: '%s:histogram_quantile' % slo.metric,
      labels: {
        quantile: '%.2f' % quantile,
      },
    },

    local _recordingrule = self.recordingrule(),

    alertWarning: {
      expr: |||
        %s > %.3f
      ||| % [_recordingrule.record, slo.warning],
      'for': '5m',
      labels: {
        severity: 'warning',
      },
    },

    alertCritical: {
      expr: |||
        %s > %.3f
      ||| % [_recordingrule.record, slo.critical],
      'for': '5m',
      labels: {
        severity: 'critical',
      },
    },

    grafana: {
      gauge: {
        type: 'gauge',
        title: 'P99 Latency',
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
              _recordingrule.record,
              slo.quantile,
            ],
            format: 'time_series',
          },
        ],
      },
      graph: {
        type: 'graph',
        title: 'Request Latency',
        datasource: '$datasource',
        targets: [
          {
            expr: 'max(%s) by (quantile)' % _recordingrule.record,
            legendFormat: '{{ quantile }}',
          },
        ],
        yaxes: [
          {
            show: true,
            min: '0',
            max: null,
            format: 's',
            decimals: 1,
          },
          {
            show: false,
          },
        ],
        xaxis: {
          show: true,
          mode: 'time',
          name: null,
          values: [],
          buckets: null,
        },
        yaxis: {
          align: false,
          alignLevel: null,
        },
        lines: true,
        fill: 2,
        linewidth: 1,
        dashes: false,
        dashLength: 10,
        paceLength: 10,
        points: false,
        pointradius: 2,
        thresholds: [
          {
            value: slo.warning,
            colorMode: 'warning',
            op: 'gt',
            fill: true,
            line: true,
            yaxis: 'left',
          },
          {
            value: slo.critical,
            colorMode: 'critical',
            op: 'gt',
            fill: true,
            line: true,
            yaxis: 'left',
          },
        ],
      },
    },
  },
}
