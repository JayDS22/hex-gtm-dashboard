-- P1 sparkline companion: ARR by month, trailing 12 months ending at as_of_date.

SELECT
  metric_time__month,
  arr
FROM {{
  semantic_layer.query(
    metrics=['arr'],
    group_by=['metric_time__month'],
    where=[
      "{{ TimeDimension('metric_time', 'month') }} >= DATEADD(month, -12, '{{ as_of_date }}')",
      "{{ TimeDimension('metric_time', 'month') }} <= '{{ as_of_date }}'",
      "{{ Dimension('account__segment') }} IN {{ segment | sqlsafe }}",
      "{{ Dimension('account__region') }}  IN {{ region  | sqlsafe }}"
    ],
    order_by=['metric_time__month']
  )
}}
