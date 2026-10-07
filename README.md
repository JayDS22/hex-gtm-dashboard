# hex-gtm-dashboard

Executive GTM command center built in Hex, powered by the dbt + MetricFlow semantic layer from the companion project [`gtm-semantic-layer`](https://github.com/JayDS22/gtm-semantic-layer). Four scrollable sections, seven panels, four filters, one live URL.

**Companion repo** (source of truth for metrics): [github.com/JayDS22/gtm-semantic-layer](https://github.com/JayDS22/gtm-semantic-layer)
**Published Hex app URL:** `TBD` (link added once the app is published from `hex.tech`)

## Why Hex

Hex is named in the target JD and ships a first-class dbt Semantic Layer integration. This repo exists because the Hex app itself is hosted on `hex.tech` and cannot be committed as source; what IS committed is the recipe. Pointing a reviewer at this repo lets them read the architecture, the exact SQL for every panel, and the build steps without needing a Hex account. Once the app is published, the live URL goes at the top of this README.

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
| P7 | ARR YoY matrix | `arr` growth | heatmap |

Metric names match the companion repo exactly (verified against `models/semantic/` in `gtm-semantic-layer`). The design doc proposed slightly different names (e.g. `net_revenue_retention`, `pipeline_coverage_ratio`); the queries in `queries/` are rewritten to the real names.

## What's in this repo

| Path | What's here |
|---|---|
| `queries/` | 7 ready-to-paste SQL cells, one per panel, with Hex Jinja parameter bindings |
| `docs/architecture.md` | Panel layout + Mermaid data flow + filter semantics |
| `docs/hex-build-guide.md` | Step-by-step for the Hex-side build (workspace setup, SL connection, cell order, publish) |
| `BUILD-LOG.md` | Day-by-day progress; mirrors the companion repo's convention |

## Build status

- [x] Day 1 — Repo scaffolded, 7 SQL queries rewritten against real companion metrics, architecture + build-guide docs
- [ ] Day 2 — Build in `hex.tech`, wire the 7 panels, mobile layout pass
- [ ] Day 3 — Publish, embed screenshots + published URL in this README, final polish

Days 2 and 3 happen inside Hex (hosted). This repo documents what the app contains; the live app URL will go at the top of this README once published.

## Attribution

Dashboard composition and panel structure follow design doc `_designs/04-anthropic-hex-app.md` in the parent workspace. The companion dbt + MetricFlow layer at `gtm-semantic-layer` is the source of truth for every metric; this repo is the presentation plane only (no business logic lives here, no ETL inside Hex).
