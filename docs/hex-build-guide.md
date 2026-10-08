# Hex build guide

Step-by-step to turn this repo into a published Hex app. Target: Hex Community tier (free, forever). ~90 minutes end-to-end using the CSV-via-HTTPS path.

## 0. Prerequisites

- Hex account on the Community tier (`hex.tech`, free, no credit card).
- No warehouse connection needed. The CSVs under `data/` in this repo are the data source; Hex reads them over HTTPS via a Python cell.

**Why the CSV path, not a warehouse connector?** See the README section "Data source: static CSV snapshots (deliberate)." Short version: no 14-30 day trial to expire mid-interview process, zero cost, reviewer-auditable data.

## 1. Workspace + project

1. Create a new Hex project. Name it `GTM Command Center`.
2. No data connection setup needed — skip Hex's connection wizard. The next step loads data via Python.

## 2. Load data (one Python cell)

Add a Python cell at the top of the project, name it `load_data`, paste:

```python
import pandas as pd
BASE = "https://raw.githubusercontent.com/JayDS22/hex-gtm-dashboard/main/data"

arr_trend         = pd.read_csv(f"{BASE}/arr_trend.csv",         parse_dates=['metric_time__month'])
nrr_by_cohort     = pd.read_csv(f"{BASE}/nrr_by_cohort.csv",     parse_dates=['cohort_arr_row__cohort_month__month', 'metric_time__month'])
logo_retention    = pd.read_csv(f"{BASE}/logo_retention.csv",    parse_dates=['cohort_arr_row__cohort_month__month', 'metric_time__month'])
pipeline_strict   = pd.read_csv(f"{BASE}/pipeline_strict.csv",   parse_dates=['metric_time__quarter'])
pipeline_qtd      = pd.read_csv(f"{BASE}/pipeline_qtd.csv",      parse_dates=['metric_time__quarter'])
funnel_conv       = pd.read_csv(f"{BASE}/funnel_conv.csv",       parse_dates=['metric_time__week'])
cac_payback       = pd.read_csv(f"{BASE}/cac_payback.csv",       parse_dates=['metric_time__quarter'])
rule_of_40        = pd.read_csv(f"{BASE}/rule_of_40.csv",        parse_dates=['metric_time__quarter'])
arr_growth        = pd.read_csv(f"{BASE}/arr_growth.csv",        parse_dates=['metric_time__quarter'])
```

Run the cell once. Hex now has 9 dataframes available to all downstream cells.

## 3. Filter bar (top of project)

Create 4 Input cells across the top:

| Input cell | Type | Parameter name | Default |
|---|---|---|---|
| `in_as_of_date` | Date picker | `as_of_date` | 2026-10-01 (latest observed) |
| `in_segment` | Multi-select | `segment` | ALL (options: SMB, MM, ENT, ALL) |
| `in_region` | Multi-select | `region` | ALL (options: NAMER, EMEA, APAC, LATAM, ALL) |
| `in_grain` | Single-select | `grain` | Month (options: Week, Month, Quarter) |

**Note on filter wiring:** the CSVs are pre-aggregated by metric_time grain and don't carry segment/region as columns on every panel. Filters are decorative in v1 — they display in the UI but don't yet slice the data. v2 adds a Python filter cell that masks dataframes before each chart. Honest tradeoff: ships today without, v2 adds slicing when segment/region columns are added to the CSV exports.

Add a Markdown header cell above the inputs:
```
# GTM Command Center
Data as-of 2026-10-01, sourced from gtm-semantic-layer DuckDB warehouse. [GitHub](https://github.com/JayDS22/hex-gtm-dashboard)
```

## 4. Charts (one per panel)

For each panel, add a Chart cell and point its "Dataframe" dropdown at one of the 9 loaded dataframes.

| Panel | Dataframe | Chart type | Key config |
|---|---|---|---|
| P1 ARR today (big number) | `arr_trend` | Single-value / Big number | Value: last row's `arr` column; subtitle: "ARR, Oct 2026" |
| P1 sparkline | `arr_trend` | Line chart | X: `metric_time__month`, Y: `arr`, no axes, minimalist |
| P2 NRR by cohort | `nrr_by_cohort` | Horizontal bar | Y: `cohort_arr_row__cohort_month__month`, X: `nrr`; sort Y descending |
| P3 Logo retention | `logo_retention` | Line chart | X: `metric_time__month`, Y: `logo_retention`, series: `cohort_arr_row__cohort_month__month` |
| P4 Pipeline coverage | `pipeline_strict` | Bar chart | X: `team`, Y: `pipeline_coverage`; horizontal threshold at 3.0 |
| P4b Pipeline (QtD) | `pipeline_qtd` | Bar chart | X: `team`, Y: `pipeline_coverage_qtd`; same threshold |
| P5 Funnel conversion | `funnel_conv` | Line chart | X: `metric_time__week`, 3 series: `mql_to_sql_conv`, `sql_to_won_conv`, `activation_rate` |
| P6 CAC payback | `cac_payback` | Bar chart | X: `metric_time__quarter`, Y: `cac_payback_months`; horizontal threshold at 18 |
| P7 Rule-of-40 | `rule_of_40` | Bar + reference line | X: `metric_time__quarter`, Y: `rule_of_40`; horizontal threshold at 40 (Bessemer healthy line) |
| P7b ARR growth | `arr_growth` | Line chart | X: `metric_time__quarter`, Y: `arr_qoq_annualized_growth_pct` |

Each chart cell takes ~2 minutes to configure in Hex's UI. Total: ~20 minutes for all 10 charts.

## 5. Section headers (Markdown cells)

Insert 4 Markdown divider cells to split the layout into sections:
```
## 📈 Revenue Trajectory
## 👥 Retention & Expansion
## 🎯 Pipeline & Funnel
## ⚡ Efficiency
```

Place charts under their section:
- Revenue Trajectory: P1 big number + P1 sparkline
- Retention & Expansion: P2 + P3
- Pipeline & Funnel: P4 + P4b + P5
- Efficiency: P6 + P7 + P7b

## 6. Appendix (bottom of project)

Add a Markdown cell with:
- Methodology: "All metrics sourced from the companion [gtm-semantic-layer](https://github.com/JayDS22/gtm-semantic-layer) repo (dbt-core + MetricFlow). Full definitions, grain, and confidence tiers in the companion `docs/metric-glossary.md`."
- Freshness: "Data snapshot refreshed on 2026-10-08. Re-exported from the semantic layer via `scripts/export_csvs.sh`."
- Synthetic-data disclaimer: "Underlying data is a synthetic 12-month SaaS seed included in the companion repo for public demo purposes. Numbers are illustrative, not real company data."

## 7. Publish

- Hex app settings → Publish → enable "Anyone with the link can view."
- In reader view: hide the `load_data` Python cell and the filter cells. Show only Markdown headers + Charts.
- Copy the published URL.
- Replace `TBD` at the top of the repo's README with the published URL. Commit.

## 8. (Optional) Mobile pass

- Open the published URL on iPhone, check for horizontal scroll.
- In Hex, enable mobile layout; move the sticky filter bar to a collapsible menu on mobile.
- Verify each chart renders without text truncation.

## When the Pro trial expires

- All 10 charts and the Markdown cells → stay live on Community (within 5-published-app limit).
- The `load_data` Python cell → stays functional (Python + HTTPS to GitHub is a Community feature).
- The data → stays frozen at the snapshot in `data/`. Re-exporting with `scripts/export_csvs.sh` and committing to GitHub refreshes the Hex app on next open.

## Refreshing the data

Any time the companion `gtm-semantic-layer` ships new metrics or a confidence-tier change, re-export:

```bash
cd /path/to/hex-gtm-dashboard
bash scripts/export_csvs.sh
git add data/
git commit -m "Refresh CSV snapshots from gtm-semantic-layer"
git push
```

The Hex app auto-pulls the new CSVs on next page load. No Hex-side changes needed.
