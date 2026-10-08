#!/bin/bash
# Export the 8 panel CSVs from the companion gtm-semantic-layer DuckDB warehouse.
# Hex app at hex.tech reads these via raw.githubusercontent.com (Path B).
# Re-run after any semantic-layer change to refresh the live demo.
#
# Prereq: companion repo built locally with `make up`.

set -euo pipefail

GTM_REPO="${GTM_REPO:-$HOME/Documents/Github_Personal/work/portfolio-projects/gtm-semantic-layer}"
MF="$GTM_REPO/.venv/bin/mf"
OUT="$(cd "$(dirname "$0")/.." && pwd)/data"

if [ ! -x "$MF" ]; then
  echo "mf binary not found at $MF. Build the companion repo first:"
  echo "  cd $GTM_REPO && make up"
  exit 1
fi

mkdir -p "$OUT"
cd "$GTM_REPO"

run() {
  local name="$1"; shift
  echo "exporting $name..."
  "$MF" query "$@" --csv "$OUT/$name.csv" >/dev/null
}

# P1 ARR current (big number). Take the latest observed month.
run arr_trend         --metrics arr                            --group-by metric_time__month   --order metric_time__month

# P2 NRR by segment. Group by cohort month; we flatten the "by segment" later in Hex via a
# Python cell since gtm-semantic-layer doesn't expose segment as an NRR dim yet.
run nrr_by_cohort     --metrics nrr                            --group-by metric_time__month,cohort_arr_row__cohort_month__month --order metric_time__month --limit 200

# P3 Logo retention trend. Trailing cohort grid.
run logo_retention    --metrics logo_retention                 --group-by metric_time__month,cohort_arr_row__cohort_month__month --order metric_time__month --limit 200

# P4 Pipeline coverage by team x quarter (strict + QtD).
run pipeline_strict   --metrics pipeline_coverage              --group-by metric_time__quarter,team            --order metric_time__quarter
run pipeline_qtd      --metrics pipeline_coverage_qtd          --group-by metric_time__quarter,team            --order metric_time__quarter

# P5 Weighted pipeline ARR by quarter. Replaces the funnel conversion panel
# because the demo product_events seed is too thin to compute meaningful
# MQL/SQL/activation conversions; weighted_pipeline_arr uses the opportunity
# amount x stage-probability data which is dense + GTM-relevant.
run weighted_pipeline --metrics weighted_pipeline_arr                         --group-by metric_time__quarter --order metric_time__quarter

# (optional, kept for reference) Original funnel export — commented out until
# product_events seed carries dense funnel-stage data.
# run funnel_conv     --metrics mql_to_sql_conv,sql_to_won_conv,mql_to_won_conv,activation_rate --group-by metric_time__week --order metric_time__week

# P6 CAC payback by quarter.
run cac_payback       --metrics cac_payback_months             --group-by metric_time__quarter --order metric_time__quarter

# P7 Efficiency panel: Rule-of-40 (growth + margin, Day 6 upgrade) by quarter.
# Replaces the design-doc "ARR by segment x month" heatmap because segment isn't
# yet exposed on the ARR metric in gtm-semantic-layer; Rule-of-40 is a stronger
# efficiency signal for a GTM executive dashboard anyway.
run rule_of_40        --metrics rule_of_40                     --group-by metric_time__quarter --order metric_time__quarter

# Efficiency companion: ARR QoQ-annualized growth (the growth-rate term of Rule-of-40).
run arr_growth        --metrics arr_qoq_annualized_growth_pct  --group-by metric_time__quarter --order metric_time__quarter

echo "---"
echo "wrote $(ls "$OUT" | wc -l | tr -d ' ') CSVs to $OUT"
ls -la "$OUT"
