{
  errors(param):: {
    local slo = {
      metric: error 'must set metric for errors',
      selectors: error 'must set selectors for errors',
    } + param,

    local recordingrule = {
      expr: |||
        sum(label_replace(rate(%s{%s}[%s]), "status_code", "${1}xx", "code", "([0-9])..")) by (status_code)
      ||| % [
        slo.metric,
        std.join(',', slo.selectors),
        slo.rate,
      ],
      record: 'status_code:%s:rate%s:sum' % [slo.metric, slo.rate],
      labels: {
        [s[0]]: std.strReplace(s[1], '"', '')
        for s in [
          std.split(s, '=')
          for s in slo.selectors
        ]
      },
    },
    recordingrule: recordingrule,

    alertWarning: {
      expr: |||
        %s{status_code!~"2.."} * 100 / %s > %s
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
      expr: '%s{status_code!~"2.."} * 100 / %s > %s' % [recordingrule.record, recordingrule.record, slo.critical],
      'for': '5m',
      labels: {
        severity: 'critical',
      },
    },

    grafana: {
      graph: {
        span: 12,
        aliasColors: {
          '1xx': '#EAB839',
          '2xx': '#7EB26D',
          '3xx': '#6ED0E0',
          '4xx': '#EF843C',
          '5xx': '#E24D42',
          success: '#7EB26D',
          'error': '#E24D42',
        },
        datasource: '$datasource',
        legend: {
          avg: false,
          current: false,
          max: false,
          min: false,
          show: true,
          total: false,
          values: false,
        },
        targets: [
          {
            expr: '%s' % recordingrule.record,
            format: 'time_series',
            intervalFactor: 2,
            legendFormat: '{{status_code}}',
            refId: 'A',
            step: 10,
          },
        ],
        title: 'HTTP Response Codes',
        tooltip: {
          shared: true,
          sort: 0,
          value_type: 'individual',
        },
        type: 'graph',
      },
    },
  },
}
