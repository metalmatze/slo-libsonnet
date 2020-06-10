local util = import '_util.libsonnet';

{
  errors(param):: {
    local slo = {
      metric: error 'must set metric for errors',
      selectors: [],
      errorSelectors: ['code=~"5.."'],
      rate: '5m',
    } + param,

    local labels = util.selectorsToLabels(slo.selectors),

    alerts: [
      {
        expr: |||
          (
            sum(rate(%(metric)s{%(errorSelectors)s}[%(rate)s]))
            /
            sum(rate(%(metric)s{%(selectors)s}[%(rate)s]))
          )
          > %(severity)f
        ||| % {
          metric: slo.metric,
          selectors: std.join(',', slo.selectors),
          errorSelectors: std.join(',', slo.selectors + slo.errorSelectors),
          rate: slo.rate,
          severity: severity.percent,
        },
        'for': '5m',
        labels: labels {
          severity: severity.name,
        },
      }
      for severity in [
        { name: 'warning', percent: slo.warning },
        { name: 'critical', percent: slo.critical },
      ]
    ],

    grafana: {
      graph: {
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
            expr: '%s{%s}' % [slo.metric, labels],
            format: 'time_series',
            intervalFactor: 2,
            legendFormat: '{{code}}',
            refId: 'A',
            step: 10,
          },
        ],
        seriesOverrides: [
          {
            alias: '/2../',
            color: '#56A64B',
          },
          {
            alias: '/3../',
            color: '#F2CC0C',
          },
          {
            alias: '/4../',
            color: '#3274D9',
          },
          {
            alias: '/5../',
            color: '#E02F44',
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
