-- P4: Pipeline coverage by team x quarter. Gauge + bar combo.
-- Returns both strict (`pipeline_coverage`) and inclusive (`pipeline_coverage_qtd`) numbers so the
-- Hex panel can toggle between the two definitions (see companion repo's
-- skills/faq/pipeline-coverage-strict-vs-qtd.md).

SELECT
  metric_time__quarter,
  team,
  pipeline_coverage,
  pipeline_coverage_qtd,
  quota_arr,
  open_pipeline_arr,
  qtd_pipeline_arr
FROM {{
  semantic_layer.query(
    metrics=[
      'pipeline_coverage',
      'pipeline_coverage_qtd',
      'quota_arr',
      'open_pipeline_arr',
      'qtd_pipeline_arr'
    ],
    group_by=['metric_time__quarter', 'team'],
    where=[
      "{{ TimeDimension('metric_time', 'quarter') }} = DATE_TRUNC('quarter', '{{ as_of_date }}')"
    ],
    order_by=['team']
  )
}}
