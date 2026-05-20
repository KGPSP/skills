# CLAUDE.md

> Skopiuj ten plik do **root** Twojego projektu (`<project>/CLAUDE.md`). Claude Code automatycznie ładuje go do kontekstu w każdej sesji.

---

## Library Currency (auto-invoke context7)

Zawsze używaj **context7 MCP** gdy potrzebujesz:

- generowania kodu z biblioteki/frameworku (`import { X } from 'lib'`),
- kroków setup/configuration (`next.config.js`, `vite.config.ts`, `playwright.config.ts`),
- dokumentacji API/biblioteki/frameworka,
- migracji między wersjami,
- weryfikacji czy używasz aktualnej składni.

To znaczy: **automatycznie** wywołuj tools `mcp__context7__resolve-library-id` + `mcp__context7__get-library-docs` bez czekania aż user napisze "use context7".

**Fallback chain (jeśli context7 nie ma biblioteki):**

1. **DeepWiki MCP** → `mcp__deepwiki__read_wiki_contents`
2. **WebFetch** oficjalnej dokumentacji
3. **`npm view` + `cat node_modules/{lib}/README.md`** (offline)

**Audit trail:** po każdym currency check dopisz breadcrumb:

```bash
bash scripts/append-breadcrumb.sh "<actor>" "library_currency_checked" \
  "$(jq -nc --arg s "<sprint>" --arg lib "<library>" --arg v "<version>" --arg src "context7|deepwiki|webfetch|npm-jsdoc" \
    '{sprint: $s, library: $lib, version_used: $v, source: $src}')"
```

Pełen protokół: `dev/agent-teams-builder/references/library-currency-protocol.md`.

---

## Agent Teams workflow (jeśli skill agent-teams-builder zainstalowany)

Ten projekt używa `agent-teams-builder` do orkiestracji zespołu sub-agentów:

- **planner** — zamienia prompt w `state/plan.md`
- **generator** — implementuje kod wg kontraktu sprintu
- **evaluator** — uruchamia testy przez Playwright/Chrome, generuje evidence
- **playwright-runner** (jeśli `playwright-test-suite` zainstalowany) — dedykowany QA executor

Konwencje:

- **State files** w `state/` (NIE w root): `plan.md`, `contracts/sprint-N.json`, `breadcrumbs.json` (append-only), `evidence/sprint-N/`.
- **Sub-agents** w `.claude/agents/*.md` (skopiowane z `dev/agent-teams-builder/agents/` + `dev/playwright-test-suite/agents/`).
- **Walidatory** uruchamiane przed każdą fazą — `scripts/verify-*.sh`.

---

## Tone

- **Imperatyw**, nie "powinieneś". "Weryfikuj X" zamiast "powinieneś sprawdzić X".
- **Twardy dowód, nie deklaracja.** Każdy status `done` musi mieć artefakt (log/screenshot/test output).
- **DAMP w testach** — test czyta się jak specyfikacja, NIE jak abstrakcyjny helper.
