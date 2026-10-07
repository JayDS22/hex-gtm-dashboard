-- P5: Funnel conversion (MQL -> SQL -> Won proxy). Funnel chart.
-- Trailing 3 months ending at as_of_date, no segment slice in v1 (funnel is at user grain, not account).
-- Companion metrics `mql_to_sql_conv`, `sql_to_won_conv`, `mql_to_won_conv` are same-period cohort
-- proxies, flagged `confidence_tier: evolving` in the companion skill files; the Hex panel surfaces
-- a tooltip noting the proxy for exec readers.

SELECT
  metric_time__week,
  funnel_mqls,
  funnel_sqls,
  funnel_wons,
  mql_to_sql_conv,
  sql_to_won_conv,
  mql_to_won_conv
FROM {{
  semantic_layer.query(
    metrics=[
      'funnel_mqls',
      'funnel_sqls',
      'funnel_wons',
      'mql_to_sql_conv',
      'sql_to_won_conv',
      'mql_to_won_conv'
    ],
    group_by=['metric_time__week'],
    where=[
      "{{ TimeDimension('metric_time', 'week') }} >= DATEADD(week, -12, '{{ as_of_date }}')",
      "{{ TimeDimension('metric_time', 'week') }} <= '{{ as_of_date }}'"
    ],
    order_by=['metric_time__week']
  )
}}
