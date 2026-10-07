-- P6: CAC payback months by quarter. Horizontal bar with a threshold line at 18 months.
-- Companion metric `cac_payback_months` is segment-weighted since Day 5 of gtm-semantic-layer
-- (real new_arr by segment from fct_mrr_movement x dim_account.segment; GM + mix seeded from
-- segment_margins); flagged `confidence_tier: stable`.

SELECT
  metric_time__quarter,
  cac_payback_months,
  sm_spend,
  segment_weighted_cac_denom
FROM {{
  semantic_layer.query(
    metrics=['cac_payback_months', 'sm_spend', 'segment_weighted_cac_denom'],
    group_by=['metric_time__quarter'],
    where=[
      "{{ TimeDimension('metric_time', 'quarter') }} >= DATEADD(quarter, -4, '{{ as_of_date }}')",
      "{{ TimeDimension('metric_time', 'quarter') }} <= DATE_TRUNC('quarter', '{{ as_of_date }}')"
    ],
    order_by=['metric_time__quarter']
  )
}}
