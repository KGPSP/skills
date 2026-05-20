# CHANGELOG — playwright-test-suite

## [v1.0.0] — 2026-05-20 — initial release

### Added

- **SKILL.md** (~250 linii, limit ≤500) — 5-fazowa procedura QA (setup → smoke → UI → DevTools → a11y → visual) z exit criteria per faza.
- **agents/playwright-runner.md** — dedykowany sub-agent Claude Code (frontmatter `name/description/tools/model`, system prompt z workflow). Tools: Bash, Read, Write (ograniczone do state/evidence/), Glob, Grep. BEZ Edit (read-only na kodzie aplikacji).
- **references/** (7 protokołów ładowanych progresywnie):
  - `setup-protocol.md` — bootstrap Node/Playwright/axe-core/pixelmatch
  - `smoke-protocol.md` — build + start + HTTP + smoke spec
  - `playwright-ui-protocol.md` — keyboard/mouse/forms/persistencja, best practices
  - `chrome-devtools-protocol.md` — HAR/console/Core Web Vitals (LCP/FCP/CLS/INP)
  - `accessibility-protocol.md` — axe-core WCAG 2.1 AA, klasyfikacja violations
  - `visual-regression-protocol.md` — Playwright `toHaveScreenshot()` + pixelmatch
  - `agent-teams-integration.md` — protokół delegacji z `evaluator` (agent-teams-builder)
- **scripts/** (7 deterministycznych orchestratorów):
  - `init-playwright.sh` — bootstrap zależności
  - `run-smoke.sh` — faza 1
  - `run-ui-tests.sh` — faza 2 (generuje testy z templates per kontrakt sprintu)
  - `run-devtools-trace.sh` — faza 3
  - `run-a11y.sh` — faza 4
  - `run-visual-diff.sh` — faza 5
  - `aggregate-evidence.sh` — agreguje wszystkie metadata w `qa-summary.json`
- **templates/** (7 Playwright spec templates):
  - `playwright.config.ts.tmpl` — config z full trace + JSON+HTML reporter + 3 projekty (chromium/firefox/webkit)
  - `smoke.spec.ts.tmpl` — landmark check + console errors + response time
  - `ui-interactions.spec.ts.tmpl` — generic per criterion z `{{CRITERION_ID}}` placeholderem
  - `layout.spec.ts.tmpl` — boundingBox per viewport (desktop/tablet/mobile)
  - `perf.spec.ts.tmpl` — Core Web Vitals przez Performance API
  - `a11y.spec.ts.tmpl` — `@axe-core/playwright` z WCAG tags
  - `visual.spec.ts.tmpl` — multi-viewport screenshot compare z animation disable

### Integration with agent-teams-builder

- `dev/agent-teams-builder/agents/evaluator.md` zaktualizowany — sekcja "Delegacja do playwright-runner" z gotowym wzorcem `Task(subagent_type: "playwright-runner", ...)`.
- `dev/agent-teams-builder/scripts/verify-role-isolation.sh` zaktualizowany — uznaje `playwright-runner` jako allowed producer evidence files.

### Coexistence

Skill **standalone-capable** (działa solo bez agent-teams-builder) ALE **integration-first** — przy wywołaniu z Agent Teams generuje evidence zgodnie z kontraktem sprintu i schematem oczekiwanym przez Evaluatora.

### Source

- Playwright docs ([playwright.dev](https://playwright.dev))
- axe-core ([github.com/dequelabs/axe-core](https://github.com/dequelabs/axe-core))
- Core Web Vitals ([web.dev/vitals](https://web.dev/vitals/))
- `DOC/agent-teams-generator-ewaluator.md` §4 (rubryka 4-filarowa), §6 (tooling QA)
- `DOC/material_skill.md` §8 (5 Non-negotiables), `DOC/since_skill.md` §2 (5 filarów)
