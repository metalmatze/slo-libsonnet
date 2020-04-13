local util = import '_util.libsonnet';
local httpRatesLib = import 'http-rates.libsonnet';
{
  errorburn(param):: {
    local slo = {
      alertName: 'ErrorBudgetBurn',
      metric: error 'must set metric for error burn',
      recordingRuleMetric: self.metric,
      selectors: error 'must set selectors for error burn',
      errorBudget: error 'must set errorBudget for error burn',
      labels: [],
      codeSelector: 'code',
      rates: ['5m', '30m', '1h', '2h', '6h', '1d', '3d'],
    } + param,

    local httpRates = httpRatesLib.httpRates(slo),
    local errorRates = httpRates.rateRules,
    local errorPercentages = httpRates.errorRateRules,

    recordingrules: errorRates + errorPercentages,

    local labels =
      util.selectorsToLabels(slo.selectors) +
      util.selectorsToLabels(slo.labels),

    local multiBurnRate30d = [
      {
        alert: slo.alertName,
        expr: |||
          (
            %s{%s} > (14.4*%f)
            and
            %s{%s} > (14.4*%f)
          )
          or
          (
            %s{%s} > (6*%f)
            and
            %s{%s} > (6*%f)
          )
        ||| % [
          errorPercentages[2].record,
          std.join(',', slo.selectors),
          slo.errorBudget,
          errorPercentages[0].record,
          std.join(',', slo.selectors),
          slo.errorBudget,
          errorPercentages[4].record,
          std.join(',', slo.selectors),
          slo.errorBudget,
          errorPercentages[1].record,
          std.join(',', slo.selectors),
          slo.errorBudget,
        ],
        labels: labels {
          severity: 'critical',
        },
        annotations: {
          message: 'High requests error budget burn for %s (current value: {{ $value }})' % [std.strReplace(std.join(',', slo.selectors), '"', '')],
        },
      },
      {
        alert: slo.alertName,
        expr: |||
          (
            %s{%s} > (3*%f)
            and
            %s{%s} > (3*%f)
          )
          or
          (
            %s{%s} > (%f)
            and
            %s{%s} > (%f)
          )
        ||| % [
          errorPercentages[5].record,
          std.join(',', slo.selectors),
          slo.errorBudget,
          errorPercentages[3].record,
          std.join(',', slo.selectors),
          slo.errorBudget,
          errorPercentages[6].record,
          std.join(',', slo.selectors),
          slo.errorBudget,
          errorPercentages[4].record,
          std.join(',', slo.selectors),
          slo.errorBudget,
        ],
        labels: labels {
          severity: 'warning',
        },
        annotations: {
          message: 'High requests error budget burn for %s (current value: {{ $value }})' % [std.strReplace(std.join(',', slo.selectors), '"', '')],
        },
      },
    ],

    alerts: multiBurnRate30d,
  },
}
