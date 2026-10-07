-- P1: ARR today (big number).
-- Reads from the companion gtm-semantic-layer via the dbt Semantic Layer SQL API.
-- Cell type: SQL. Parameters bound to top-bar filters (segment, region).
-- as_of_date defaults to today; sparkline uses the 12M query p1_arr_trend.sql.

SELECT
  metric_time__day,
  arr
FROM {{
  semantic_layer.query(
    metrics=['arr'],
    group_by=['metric_time__day'],
    where=[
      "{{ TimeDimension('metric_time', 'day') }} = '{{ as_of_date }}'",
      "{{ Dimension('account__segment') }} IN {{ segment | sqlsafe }}",
      "{{ Dimension('account__region') }}  IN {{ region  | sqlsafe }}"
    ]
  )
}}
