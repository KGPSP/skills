# playwright-test-suite

> Dedykowany skill QA dla aplikacji webowych. Wykonuje pełen zestaw testów E2E przez Playwright CLI + Chrome DevTools + axe-core + pixel-diff w 5 fazach z generowaniem strukturyzowanego evidence.

## Kiedy używać

| Tryb | Trigger | Co produkuje |
|---|---|---|
| **Standalone** | User w głównym oknie pisze `/test`, "uruchom playwright" | `qa-report/{ts}/qa-summary.json` + HTML report |
| **Sub-agent w pętli Agent Teams** | Evaluator z `agent-teams-builder` wywołuje przez `Task(subagent_type: "playwright-runner")` | `state/evidence/sprint-{n}/qa-summary.json` zgodne z kontraktem |
| **CI/CD** | GitHub Actions / pre-merge hook | JUnit XML + JSON + HTML reports |

**NIE używaj dla:**
- Testów jednostkowych (to robi Generator w swoim workflow przez `npm test`).
- Tylko API bez UI (`curl`/`httpie` wystarczą).
- Eksploracji kodu testów.

## 5 faz testowania

| # | Faza | Co sprawdza | Narzędzie | Evidence |
|---|---|---|---|---|
| 0 | Setup | Node 18+, Playwright installed, config OK | `npx playwright --version` | n/a |
| 1 | Smoke | Build clean + app responds + HTTP 200 | bash + curl + Playwright smoke spec | `smoke.log`, `smoke.metadata.json` |
| 2 | UI Interactions | Klawiatura, mysz, forms, persistencja, layout | Playwright CLI | `ui/{C-XX}/before.png + after.png + trace.zip` |
| 3 | DevTools (perf/network/console) | Core Web Vitals (LCP/FCP/CLS/INP), HAR, 0 console errors | Playwright tracing + Performance API | `perf/{vitals.json, console.log, network.har}` |
| 4 | Accessibility | WCAG 2.1 AA — 0 critical/serious violations | `@axe-core/playwright` | `a11y/violations.json`, `axe-report.html` |
| 5 | Visual regression | Pixel-diff vs baseline screenshots | Playwright `toHaveScreenshot()` | `visual/{view}/{current,baseline,diff}.png` |

## Struktura katalogu

```
playwright-test-suite/
├── SKILL.md                          ← główny entry, frontmatter pełny
├── README.md                         ← ten plik
├── agents/
│   └── playwright-runner.md          ← sub-agent Claude Code (.claude/agents/)
├── references/                       ← progresywnie ładowane protokoły
│   ├── setup-protocol.md             ← Faza 0
│   ├── smoke-protocol.md             ← Faza 1
│   ├── playwright-ui-protocol.md     ← Faza 2
│   ├── chrome-devtools-protocol.md   ← Faza 3
│   ├── accessibility-protocol.md     ← Faza 4
│   ├── visual-regression-protocol.md ← Faza 5
│   └── agent-teams-integration.md    ← integracja z agent-teams-builder
├── scripts/                          ← CLI orchestrators
│   ├── init-playwright.sh
│   ├── run-smoke.sh
│   ├── run-ui-tests.sh
│   ├── run-devtools-trace.sh
│   ├── run-a11y.sh
│   ├── run-visual-diff.sh
│   └── aggregate-evidence.sh
├── templates/                        ← Playwright spec templates
│   ├── playwright.config.ts.tmpl
│   ├── smoke.spec.ts.tmpl
│   ├── ui-interactions.spec.ts.tmpl
│   ├── layout.spec.ts.tmpl
│   ├── perf.spec.ts.tmpl
│   ├── a11y.spec.ts.tmpl
│   └── visual.spec.ts.tmpl
└── assets/                           ← (reserved for future few-shot examples)
```

## Quick Start — Standalone

```bash
cd <your-web-project>

# 1. Bootstrap (instaluje @playwright/test, @axe-core/playwright, pixelmatch + browsery)
bash ~/Documents/GitHub/skills/dev/playwright-test-suite/scripts/init-playwright.sh

# 2. Run smoke
bash ~/Documents/GitHub/skills/dev/playwright-test-suite/scripts/run-smoke.sh

# 3. Run UI tests (standalone — bez kontraktu)
APP_URL=http://localhost:3000 npx playwright test

# 4. Run accessibility audit
bash ~/Documents/GitHub/skills/dev/playwright-test-suite/scripts/run-a11y.sh current

# 5. Visual regression (pierwsze: --update-snapshots, potem verify)
npx playwright test visual.spec --update-snapshots  # PO Plan-Validate-Execute
```

## Quick Start — z agent-teams-builder

```bash
cd <your-web-project>

# 1. Setup sub-agentów Claude Code
mkdir -p .claude/agents

cp ~/Documents/GitHub/skills/dev/agent-teams-builder/agents/*.md .claude/agents/
cp ~/Documents/GitHub/skills/dev/playwright-test-suite/agents/playwright-runner.md .claude/agents/

# 2. Walidacja izolacji
bash ~/Documents/GitHub/skills/dev/agent-teams-builder/scripts/verify-role-isolation.sh

# 3. Setup Playwright
bash ~/Documents/GitHub/skills/dev/playwright-test-suite/scripts/init-playwright.sh

# 4. Bootstrap Agent Teams session
bash ~/Documents/GitHub/skills/dev/agent-teams-builder/scripts/init-team-state.sh "my-project"

# 5. Pętla generator-ewaluator automatycznie wywołuje playwright-runner przez Task tool.
#    Evidence trafia do state/evidence/sprint-{n}/
```

## Integracja z agent-teams-builder

`playwright-runner` (sub-agent z tego skilla) jest wywoływany przez `evaluator` z agent-teams-builder:

```
Task(
  description: "Run QA suite for sprint 2",
  subagent_type: "playwright-runner",
  prompt: "Uruchom 5 faz testowych dla sprintu 2 wg state/contracts/sprint-2.json"
)
```

`playwright-runner` zwraca `qa-summary.json`. `evaluator` mapuje fazy na kryteria kontraktu i wystawia werdykt.

Pełen protokół: [`references/agent-teams-integration.md`](references/agent-teams-integration.md).

## Wymagania

| Komponent | Wersja | Wykorzystanie |
|---|---|---|
| Node.js | ≥18 | Playwright runtime |
| `@playwright/test` | ≥1.42 | Core test framework |
| `@axe-core/playwright` | ≥4.8 | Accessibility audit |
| `pixelmatch` | ≥5.3 | Visual diff (opcjonalne) |
| `pngjs` | ≥7.0 | Pixelmatch dependency |
| Chromium / Firefox / WebKit | latest | Browser binaries (npx playwright install) |

## Sources

- [Playwright docs](https://playwright.dev/) — best practices CLI.
- [axe-core](https://github.com/dequelabs/axe-core) — WCAG rules engine.
- [Core Web Vitals](https://web.dev/vitals/) — performance metrics standard.
- Sibling skill: `dev/agent-teams-builder/` — orkiestrator który wywołuje ten skill.
- `DOC/agent-teams-generator-ewaluator.md` §4, §6 — wzorzec testowania.

## CHANGELOG

Patrz [CHANGELOG.md](CHANGELOG.md).
