-- P7: ARR by segment x reporting month. Heatmap.
-- Returns long format; the companion Hex Python cell pivots to a dense matrix for the heatmap.
-- This replaces the design-doc "segment x product_line" matrix because gtm-semantic-layer does not
-- model product_line yet; a Day 6+ companion-side mod could add a dim_product_line to lift this.

SELECT
  metric_time__month,
  account__segment,
  arr
FROM {{
  semantic_layer.query(
    metrics=['arr'],
    group_by=['metric_time__month', 'account__segment'],
    where=[
      "{{ TimeDimension('metric_time', 'month') }} >= DATEADD(month, -12, '{{ as_of_date }}')",
      "{{ TimeDimension('metric_time', 'month') }} <= '{{ as_of_date }}'",
      "{{ Dimension('account__region') }} IN {{ region | sqlsafe }}"
    ],
    order_by=['metric_time__month', 'account__segment']
  )
}}
