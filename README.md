# hex-gtm-dashboard

Executive GTM command center built in Hex, powered by the dbt + MetricFlow semantic layer from the companion project [`gtm-semantic-layer`](https://github.com/JayDS22/gtm-semantic-layer). Four scrollable sections, seven panels, four filters, one live URL.

**Companion repo** (source of truth for metrics): [github.com/JayDS22/gtm-semantic-layer](https://github.com/JayDS22/gtm-semantic-layer)
**Published Hex app URL:** `TBD` (link added once the app is published from `hex.tech`)

## Why Hex

Hex is named in the target JD and ships a first-class dbt Semantic Layer integration. This repo exists because the Hex app itself is hosted on `hex.tech` and cannot be committed as source; what IS committed is the recipe + the data snapshots the Hex app consumes. Pointing a reviewer at this repo lets them read the architecture, the exact SQL for every panel, the data the app renders, and the build steps without needing a Hex account. Once the app is published, the live URL goes at the top of this README.

## Data source: static CSV snapshots (deliberate)

This Hex app reads static CSV snapshots from `data/`, exported from the companion `gtm-semantic-layer` DuckDB warehouse via `scripts/export_csvs.sh`. Production deployments swap the CSV source for Hex's native warehouse connector; the companion repo's `profiles.yml` already carries a Snowflake profile pre-configured for exactly this swap.

Why CSVs for the public demo:
- **No time-limited trial dependency.** A Snowflake or dbt Cloud trial expires 14-30 days in and the Hex app breaks mid-interview process. Static snapshots don't expire.
- **Reviewer-safe.** The data the Hex app renders is auditable in this repo. Reviewer can diff the CSV against the semantic layer's `mf query` output and verify the Hex app isn't lying.
- **Zero cost.** Hex Community tier + CSVs via HTTPS from GitHub = permanently free, no credit card.

The CSVs are regenerated with one command whenever the semantic layer changes:
```bash
bash scripts/export_csvs.sh
```

### Loading the CSVs in Hex (paste-ready)

In your Hex project, create one Python cell with:

```python
import pandas as pd
BASE = "https://raw.githubusercontent.com/JayDS22/hex-gtm-dashboard/main/data"

arr_trend         = pd.read_csv(f"{BASE}/arr_trend.csv")
nrr_by_cohort     = pd.read_csv(f"{BASE}/nrr_by_cohort.csv")
logo_retention    = pd.read_csv(f"{BASE}/logo_retention.csv")
pipeline_strict   = pd.read_csv(f"{BASE}/pipeline_strict.csv")
pipeline_qtd      = pd.read_csv(f"{BASE}/pipeline_qtd.csv")
funnel_conv       = pd.read_csv(f"{BASE}/funnel_conv.csv")
cac_payback       = pd.read_csv(f"{BASE}/cac_payback.csv")
rule_of_40        = pd.read_csv(f"{BASE}/rule_of_40.csv")
arr_growth        = pd.read_csv(f"{BASE}/arr_growth.csv")
```

Every downstream Chart cell references these dataframe names directly. See `docs/hex-build-guide.md` for the chart-by-chart wiring.

## Dashboard composition

Four sections, seven panels, sticky top filter bar (as-of date, segment, region, product line). See [`docs/architecture.md`](docs/architecture.md) for the panel-by-panel layout and data flow diagram.

| # | Panel | Metric (from `gtm-semantic-layer`) | Chart |
|---|---|---|---|
| P1 | ARR today + 12M sparkline | `arr` | big number + sparkline |
| P2 | NRR by segment | `nrr` | horizontal bar |
| P3 | Logo retention trend (24M) | `logo_retention` | line |
| P4 | Pipeline coverage vs quota | `pipeline_coverage`, `pipeline_coverage_qtd` | gauge + bar |
| P5 | Funnel conversion | `mql_to_sql_conv`, `sql_to_won_conv` | funnel |
| P6 | CAC payback by segment | `cac_payback_months` | horizontal bar + threshold |
| P7 | Rule-of-40 + ARR growth | `rule_of_40`, `arr_qoq_annualized_growth_pct` | combo (bar + line) |

Metric names match the companion repo exactly (verified against `models/semantic/` in `gtm-semantic-layer`). The design doc proposed slightly different names (e.g. `net_revenue_retention`, `pipeline_coverage_ratio`); the queries in `queries/` are rewritten to the real names.

## What's in this repo

| Path | What's here |
|---|---|
| `data/` | 9 CSV snapshots exported from the companion `gtm-semantic-layer` DuckDB warehouse. These are what the Hex app reads via `pd.read_csv()` over HTTPS |
| `scripts/export_csvs.sh` | One-shot regenerator: runs `mf query` 9 times against the companion repo and writes the CSVs. Re-run after any semantic layer change |
| `queries/` | 7 original dbt Semantic Layer SQL cells (reference for teams wiring up a native SL connection instead of the CSV path) |
| `docs/architecture.md` | Panel layout + Mermaid data flow + filter semantics |
| `docs/hex-build-guide.md` | Step-by-step for the Hex-side build (workspace setup, data load, cell order, publish) |
| `BUILD-LOG.md` | Day-by-day progress; mirrors the companion repo's convention |

## Build status

- [x] Day 1 — Repo scaffolded, 7 SQL queries rewritten against real companion metrics, architecture + build-guide docs
- [x] Day 2 — 9 CSV snapshots exported from companion warehouse to `data/`, Hex-paste-ready Python loader in README, honest framing on CSV-vs-connector tradeoff
- [ ] Day 3 — Build in `hex.tech` using the paste-ready loader + build guide, wire 7 panels, publish, swap `TBD` for live URL

Day 3 happens inside Hex (hosted). This repo documents what the app contains; the live app URL will go at the top of this README once published.

## Attribution

Dashboard composition and panel structure follow design doc `_designs/04-anthropic-hex-app.md` in the parent workspace. The companion dbt + MetricFlow layer at `gtm-semantic-layer` is the source of truth for every metric; this repo is the presentation plane only (no business logic lives here, no ETL inside Hex).
