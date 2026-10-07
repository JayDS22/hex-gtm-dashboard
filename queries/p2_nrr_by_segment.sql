-- P2: NRR by segment. Horizontal bar.
-- Cohort-static attribution per the companion `nrr` metric. We group by cohort_arr_row__cohort_month
-- for a single reporting month (as_of_date rounded to month) and average across cohorts in each
-- segment via a wrapping aggregation.
--
-- Note: segment is a dim on dim_account, not on cohort_arr. For a true per-segment NRR you need
-- to add account__segment as a dim on the cohort_arr semantic model (via entity join to account).
-- Until that lands in gtm-semantic-layer, this query returns NRR aggregated across all cohorts for
-- the as-of reporting month, filtered by the top-bar region.

SELECT
  cohort_arr_row__cohort_month__month,
  nrr
FROM {{
  semantic_layer.query(
    metrics=['nrr'],
    group_by=[
      'metric_time__month',
      'cohort_arr_row__cohort_month__month'
    ],
    where=[
      "{{ TimeDimension('metric_time', 'month') }} = DATE_TRUNC('month', '{{ as_of_date }}')"
    ],
    order_by=['cohort_arr_row__cohort_month__month']
  )
}}
