-- P3: Logo retention, 24-month trend ending at as_of_date. Line chart.

SELECT
  metric_time__month,
  logo_retention
FROM {{
  semantic_layer.query(
    metrics=['logo_retention'],
    group_by=['metric_time__month'],
    where=[
      "{{ TimeDimension('metric_time', 'month') }} >= DATEADD(month, -24, '{{ as_of_date }}')",
      "{{ TimeDimension('metric_time', 'month') }} <= '{{ as_of_date }}'"
    ],
    order_by=['metric_time__month']
  )
}}
