# BUILD-LOG

## Day 1, 2026-10-06

**Shipped:**
- Nested git repo at `hex-gtm-dashboard/` (sibling of the companion `gtm-semantic-layer`).
- README with 60-second pitch, companion-repo link, panel table (7 panels, correct metric names), status checklist, published-URL placeholder.
- 7 SQL queries under `queries/`, one per panel, authored in dbt Semantic Layer Jinja syntax (`semantic_layer.query(...)` macros). All 7 use the ACTUAL metric names from the companion `gtm-semantic-layer` (not the design doc's proposed names, which drifted).
- `docs/architecture.md` with Mermaid data flow diagram, section/panel layout, filter semantics, non-functional targets, and a reconciliation table mapping design-doc metric names to the companion's actual names.
- `docs/hex-build-guide.md`, step-by-step for Jay to turn this repo into a published Hex app. Covers prerequisites (dbt Cloud vs Snowflake vs file-based DuckDB), workspace setup, filter inputs, cell order, chart configs, publish step, and the Day 3 mobile pass.
- `.gitignore`.

**Design-doc deviations surfaced in docs/architecture.md:**
- Metric names: `net_revenue_retention` -> `nrr`, `logo_retention_rate` -> `logo_retention`, `pipeline_coverage_ratio` -> `pipeline_coverage` (+ `pipeline_coverage_qtd` sibling), `mql_to_sql_rate` -> `mql_to_sql_conv`, `stage_weighted_pipeline_amount` -> `weighted_pipeline_arr`.
- Dimensions: `customer__segment` -> `account__segment`, `customer__region` -> `account__region`, `product__line` not yet modeled (filter is no-op in v1), `opportunity__region` -> `opportunity__owner_team` (team, not region), `lead__source` not yet modeled.
- P7 heatmap: design doc proposed `segment x product_line`; we ship `segment x reporting_month` until the companion models product_line.

**Deferred to Day 2 (inside hex.tech, not committable to this repo):**
- Create Hex workspace + dbt Semantic Layer connection.
- Paste 7 SQL cells, wire up 4 filter inputs, 2 hidden Python cells, 7 chart cells, 8 markdown cells.
- Preview app in reader mode, confirm no debug cells leak.

**Deferred to Day 3:**
- Publish to a public URL, paste it at the top of README.
- Mobile layout pass.
- Screenshot the published app, add to `docs/img/`.
- Add Loom-equivalent demo GIF via charmbracelet/vhs (mirror the companion repo's demo pattern) once the published URL exists.

**Companion repo dependency:**
This project ONLY makes sense alongside `github.com/JayDS22/gtm-semantic-layer`. If a reviewer finds this repo without the companion, add a prominent "see companion" link at the top of the README (already present).

**Carries / risks:**
- dbt Cloud Developer tier has cold-start latency; filter-change responsiveness may be worse than the <=2s NFR target. If so, Day 2 fallback is file-based DuckDB upload (loses SL abstraction, keeps the UX).
- Hex Community tier limits may constrain the number of published apps or cell counts; verify before Day 2 build starts.
