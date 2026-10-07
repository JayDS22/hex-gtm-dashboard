# Hex build guide

Step-by-step to turn this repo into a published Hex app. Target: Hex Community tier (free), ~4 hours end-to-end if the companion `gtm-semantic-layer` is already deployed on dbt Cloud or Snowflake.

## 0. Prerequisites

- Hex account on the Community tier (`hex.tech`, free).
- Companion `gtm-semantic-layer` deployed somewhere Hex can reach. Three options:
  1. **dbt Cloud Developer tier** (free, slower cold starts). Expose the semantic layer via the dbt Cloud Semantic Layer API.
  2. **Snowflake free trial** running the same models (switch profile to `snowflake` target in the companion repo's `profiles.yml`).
  3. **DuckDB uploaded as a file** (quickest for a demo; use Hex's file upload + duckdb cell, bypass the Semantic Layer API, write literal SQL against `main.core.*` tables). This loses the SL abstraction but ships in 30 min.

Pick (1) for the resume-and-interview version; pick (3) for the "see-it-today" version.

## 1. Workspace + connection

1. Create a new Hex project named `GTM Command Center`.
2. Add a new data connection:
   - Path (1) dbt Cloud: pick the dbt Semantic Layer connector, paste the environment URL + service token.
   - Path (3) DuckDB: upload `target/gtm.duckdb` from the companion repo, add a File-backed DuckDB connection.
3. Smoke test with a one-liner cell: `SELECT 1 AS ping`.

## 2. Filter bar (section S0)

Create 4 Input cells across the top:

| Input cell | Type | Parameter name | Default |
|---|---|---|---|
| `in_as_of_date` | Date picker | `as_of_date` | Today |
| `in_segment` | Multi-select | `segment` | ALL (options: SMB, MM, ENT, ALL) |
| `in_region` | Multi-select | `region` | ALL (options: NAMER, EMEA, APAC, LATAM, ALL) |
| `in_product_line` | Multi-select | `product_line` | ALL (no-op until companion models product line) |

Add a Markdown header cell above the inputs: `# GTM Command Center` + `Data as of {{refresh_ts}}` (bind to the Python cell in §4).

## 3. Paste the 7 queries

For each panel P1-P7, create a SQL cell, name it per the design doc (`q_arr_current`, `q_arr_trend`, `q_nrr_by_segment`, ...), paste the matching file from `queries/*.sql`. Hex binds `{{ as_of_date }}`, `{{ segment }}`, `{{ region }}` from the input cells automatically.

Panel source map:

| Panel | SQL file |
|---|---|
| P1 ARR + sparkline | `queries/p1_arr_current.sql` + `queries/p1_arr_trend.sql` |
| P2 NRR by cohort | `queries/p2_nrr_by_segment.sql` |
| P3 Logo retention 24M | `queries/p3_logo_retention_trend.sql` |
| P4 Pipeline coverage | `queries/p4_pipeline_coverage.sql` |
| P5 Funnel conversion | `queries/p5_funnel_conversion.sql` |
| P6 CAC payback | `queries/p6_cac_payback.sql` |
| P7 ARR segment matrix | `queries/p7_arr_segment_matrix.sql` |

## 4. Freshness + pivot cells (Python)

Add two Python cells:

```python
# py_refresh_ts (hidden)
refresh_ts = freshness.iloc[0, 0].strftime("%Y-%m-%d %H:%M UTC")
```

```python
# py_pivot_matrix (hidden), feeds P7 heatmap
seg_pivot = seg_matrix.pivot_table(
    index='account__segment', columns='metric_time__month', values='arr', fill_value=0
)
```

Mark both as hidden in reader view.

## 5. Charts (one per panel)

| Panel | Hex chart type | Key config |
|---|---|---|
| P1 | Big number + sparkline | Value: `arr_now.arr.iloc[0]`; sparkline source: `arr_12m` |
| P2 | Horizontal bar | X: `nrr`, Y: `cohort_arr_row__cohort_month__month` |
| P3 | Line | X: `metric_time__month`, Y: `logo_retention` |
| P4 | Gauge + bar | Gauge: `pipeline_coverage` by team; threshold = 3.0 |
| P5 | Funnel | Stages: MQL, SQL, Won; counts: `funnel_mqls`, `funnel_sqls`, `funnel_wons` |
| P6 | Horizontal bar + threshold line | X: `cac_payback_months`, Y: `metric_time__quarter`; threshold line at 18 |
| P7 | Heatmap | X: `metric_time__month`, Y: `account__segment`, Value: `arr` |

## 6. Appendix (section S4)

Add a Markdown cell with:
- One-paragraph methodology summary (point at companion repo `docs/metric-glossary.md`).
- Freshness note.
- Synthetic-data disclaimer.
- Links: companion repo URL, this repo URL, dbt Semantic Layer docs.

## 7. Publish

- Hex app settings, Published view, enable Public access.
- Hide: filter dropdowns in reader mode = visible; SQL cells + Python cells + debug cell = hidden.
- Copy the public URL and paste at the top of this repo's README.
- Add a screenshot of the published app to this repo under `docs/img/`.

## 8. Mobile pass (Day 3)

- Open the published URL on iPhone, check for horizontal scroll.
- In Hex, enable mobile layout; move the sticky filter bar to a collapsible menu on mobile.
- Verify each chart renders without text truncation.
