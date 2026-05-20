---
title: Smoke Protocol — build + start + HTTP responding
load-when: "Faza 1 SKILL.md — przed każdą fazą 2+"
source:
  - DOC/agent-teams-generator-ewaluator.md §4 (smoke przed Playwright)
---

# Smoke — najprostszy proof of life

> **Reguła:** smoke ≠ funkcjonalność. Smoke = aplikacja w ogóle startuje i odpowiada. Bez smoke pozostałe fazy są bez sensu (Playwright nie ma w co kliknąć).

## 1. Sekwencja smoke (twarda kolejność)

1. **Build clean** (zgodnie z wykrytym stosem — patrz `setup-protocol.md §3`).
   - Exit 0 wymagany.
   - 0 warnings (jeśli stack to wspiera — `warnings as errors` w configu).
2. **App start** w background:
   - `npm run dev &` z PID tracking.
   - Wait loop: do 30s na `curl -fsS $APP_URL`.
3. **HTTP responding** — `curl -fsS -o /dev/null -w "%{http_code}" $APP_URL` zwraca 2xx/3xx.
4. **Playwright smoke spec** — `npx playwright test smoke.spec.ts`.

## 2. smoke.spec.ts (z templates/)

Minimalny test:
- Otwarcia `APP_URL`.
- Brak console errors.
- Tytuł strony nie zawiera "Error", "404", "500".
- Co najmniej jeden widoczny element header/nav.

Pełny template: `templates/smoke.spec.ts.tmpl`.

## 3. Evidence

| Plik | Co zawiera |
|---|---|
| `smoke.log` | Pełny output build + start + curl + playwright |
| `smoke.metadata.json` | `{ produced_by: "playwright-runner", phase: "smoke", result: "passed"|"failed", duration_ms, http_code, console_errors_count }` |

## 4. Stop-gate

Smoke fail → STOP całego pipeline. Faza 2 (UI) nie wchodzi. Powód:

- Build fail → Playwright nie ma kodu do testowania.
- App nie startuje → Playwright nie ma URL do odwiedzenia.
- HTTP 4xx/5xx na root → fundamentalny błąd routingu lub deploymentu.

Werdykt: `qa-summary.json.phases.smoke.passed = false` + `blocking_failures` zawiera `smoke_failed`.

## 5. Typowe przyczyny smoke fail (debug guide)

| Objaw | Najczęstsza przyczyna | Co sprawdzić |
|---|---|---|
| Build fail z `Cannot find module 'X'` | Brak `npm install` LUB lockfile mismatch | `rm -rf node_modules && npm ci` |
| `EADDRINUSE :::3000` | Inny proces zajmuje port | `lsof -i :3000` + `kill` |
| Curl timeout 30s | App startuje za długo (slow init) | Wydłuż timeout do 60s LUB sprawdź startup logs |
| 500 na root | Brak `.env` LUB DB nie podłączona | Sprawdź env vars w `.env.example` |
| Playwright "browserType.launch: Failed to launch" | Brakuje system libs | `npx playwright install --with-deps` |

Pełen debug — `references/playwright-ui-protocol.md §debug`.
