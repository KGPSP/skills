---
title: Library Currency Protocol — weryfikacja aktualności bibliotek przez context7 + fallback chain
load-when: "Faza 1 (Planner dodaje Dependencies) LUB Faza 3 (Generator proponuje import) LUB nowa paczka w package.json"
source:
  - https://github.com/upstash/context7 (context7 MCP)
  - DOC/material_skill.md §5 (Prawo Hyruma — zmiana API to wektor regresji)
  - DOC/since_skill.md §6 (Grounding in real expertise — runbooki + traces, NIE halucynacja)
---

# Library Currency — protokół 4-poziomowy

> **Reguła:** żadnego importu/dependency bez weryfikacji aktualności. Halucynacja API to pierwszy przyczyna zerwanej pętli generator-ewaluator (Evaluator widzi: "Cannot find module" / "X is not a function" → feedback do Generatora → nieefektywne łatanie).

---

## 1. Dlaczego to obowiązkowe

LLM-y mają trening cutoff date. Konsekwencje bez context7:

- **Halucynacja API** — `useEffect(() => {}, [...], { signal })` (nie istnieje w React 18, hipotetyczne).
- **Deprecated patterns** — `React.FC` (deprecated od React 18), `componentWillReceiveProps` (od 16.3).
- **Breaking changes pominięte** — `Playwright 1.40+` zmienił locator semantyki, `axe-core 4.8+` nowe rules.
- **Złe wersje** — `npm install react@latest` ≠ `react@18.3.1`. Konfliktów peer deps nie widać bez czytania docs.

**Skutek:** Generator pisze kod który nie kompiluje → Evaluator daje feedback → Generator próbuje naprawić halucynacją na halucynację → 5 iteracji bez progresu → pivot.

---

## 2. Fallback chain (4 poziomy)

| Priorytet | Tool | Kiedy używać | MCP tool name |
|---|---|---|---|
| **1 (primary)** | **context7** | Każda dependency w `state/plan.md` LUB nowy import | `mcp__context7__resolve-library-id`, `mcp__context7__get-library-docs` |
| **2 (fallback)** | **DeepWiki MCP** | context7 nie ma biblioteki (rzadko — patrz context7.com/libraries) | `mcp__deepwiki__*` |
| **3 (fallback)** | **WebFetch** | Niszowa lib bez wiki — oficjalna dok przez URL | `WebFetch` z `<lib>.dev/docs/...` |
| **4 (offline)** | **npm/JSDoc inline** | Brak sieci / sandbox bez net access | `npm view <lib> version`, `cat node_modules/<lib>/README.md`, parsowanie `*.d.ts` |

**Reguła:** próbuj #1 → tylko jeśli "Library not found" → #2 → tylko jeśli "Not in wiki" → #3 → tylko jeśli sieć offline → #4. Loguj który poziom zadziałał.

---

## 3. Trigger phrases (kiedy wywołać)

Generator/Planner/Evaluator powinni uruchomić library currency check **PRZED**:

1. Pierwszym `import { X } from 'lib'` w sprintzie.
2. Dodaniem nowej paczki do `package.json` / `requirements.txt` / `Cargo.toml`.
3. Każdym pytaniem typu "jaki jest aktualny sposób zrobienia X w bibliotece Y".
4. Setupem konfiguracji (`next.config.js`, `vite.config.ts`, `playwright.config.ts`).
5. Migracją między wersjami (`react 17 → 18`, `next 13 → 14`).

**Bonus auto-invoke:** dodaj do `CLAUDE.md` regułę z `assets/claude-md-template.md`.

---

## 4. Format wywołania (per poziom)

### 4.1 Context7 (primary)

```
# Krok 1: Zamień nazwę na C7 ID
Tool: mcp__context7__resolve-library-id
Input: { "libraryName": "react" }
Output: { "id": "/facebook/react", "trustScore": 9.9 }

# Krok 2: Pobierz aktualną dokumentację
Tool: mcp__context7__get-library-docs
Input: {
  "context7CompatibleLibraryID": "/facebook/react",
  "topic": "useTransition hook",  # opcjonalne — filtruj
  "tokens": 5000                  # opcjonalny limit
}
Output: aktualna dok + przykłady + wersja
```

### 4.2 DeepWiki MCP (fallback)

```
Tool: mcp__deepwiki__read_wiki_structure
Input: { "repoName": "facebook/react" }
# → lista stron wiki

Tool: mcp__deepwiki__read_wiki_contents
Input: { "repoName": "facebook/react", "pageName": "hooks/useTransition" }
```

### 4.3 WebFetch (fallback)

```
Tool: WebFetch
Input: {
  "url": "https://react.dev/reference/react/useTransition",
  "prompt": "Wyciągnij aktualny sposób użycia useTransition w React 19, brakujące argumenty, breaking changes vs React 18"
}
```

### 4.4 npm/JSDoc (offline)

```bash
# Wersja
npm view react version
# → 19.0.0

# JSDoc / .d.ts
test -f node_modules/react/index.d.ts && head -200 node_modules/react/index.d.ts
test -f node_modules/react/README.md && head -100 node_modules/react/README.md

# Lista exports
node -e "console.log(Object.keys(require('react')))"
```

---

## 5. Format breadcrumb event

Po **każdym** wywołaniu currency check dopisz event:

```bash
bash scripts/append-breadcrumb.sh "<actor>" "library_currency_checked" "$(jq -nc \
  --arg s "{sprint-n}" \
  --arg lib "react" \
  --arg v "19.0.0" \
  --arg src "context7" \
  --arg api "/facebook/react" \
  --argjson dep '["componentWillReceiveProps"]' \
  '{
    sprint: $s,
    library: $lib,
    version_used: $v,
    source: $src,
    library_id: $api,
    deprecations_checked: ($dep | length > 0),
    deprecations_found: $dep,
    breaking_changes_reviewed: true,
    notes: "Used useTransition signature from v19, NOT v18"
  }')"
```

**Wymagane pola:**
- `sprint` (string)
- `library` (nazwa paczki — `package.json` "name")
- `source` ∈ `{context7, deepwiki, webfetch, npm-jsdoc}`

**Zalecane:**
- `version_used`, `library_id` (Context7 ID), `deprecations_found`, `breaking_changes_reviewed`, `notes`

Walidator `scripts/verify-library-currency.sh {sprint-n}` sprawdza obecność + strukturę.

---

## 6. Per agent — kto czego sprawdza

### Planner (Faza 1)

- **Czytane:** żadne (Planner nie wybiera bibliotek).
- **Pisane:** jeśli user wskazał konkretną bibliotekę w prompcie ("zbuduj w Next.js 15") → wywołaj context7 dla potwierdzenia wersji + breaking changes.

### Generator (Faza 4)

- **Czytane:** kontrakt sprintu — sekcja `dependencies`.
- **Pisane:** każdy nowy `import` z lib spoza biblioteki standardowej → context7 → breadcrumb.
- **NIGDY:** "pamiętam jak działa fetch" / "useEffect wymaga deps array, czyli mogę..." — to halucynacja.

### Evaluator (Faza 4)

- **Czytane:** diff Generatora (przez evidence).
- **Pisane:** jeśli widzi `deprecated` warning w console (Faza 3 chrome-devtools) → context7 → breadcrumb.

### playwright-runner (Faza 2-5)

- **Czytane:** `package.json` (versions Playwright, axe-core).
- **Pisane:** context7 dla `@playwright/test` aktualnej wersji + przy każdym setupie `playwright.config.ts`.

---

## 7. Anti-Rationalization (library-specific)

| Wymówka | Riposta |
|---|---|
| „Pamiętam jak działa fetch, znam React od lat" | **Odrzucono.** Twoja wiedza ma cutoff date. Wywołaj context7 ZAWSZE. |
| „Lib jest stabilna, nie ma breaking changes" | **Odrzucono.** Stabilność ≠ brak deprecations. Sprawdź `breaking_changes` w context7 output. |
| „Tylko mała helper paczka, nie ma sensu" | **Odrzucono.** Co najmniej `npm view {lib} version` + breadcrumb (source: npm-jsdoc). |
| „Context7 nie ma tej biblioteki" | **Riposta nie 'odrzucono':** zejdź fallback chain (DeepWiki → WebFetch → npm). Zaloguj source. |
| „Sprawdziłem w głowie, OK" | **Halucynacja. Odrzucono.** Bez breadcrumb event'u — pivot wymusi powtórkę. |
| „Tylko import typu (TypeScript), nie potrzebuje currency" | **Częściowo OK** — `.d.ts` typy też ewoluują. Dla nowych libs: context7. Dla dobrze znanych (`@types/node`) — tylko `npm view`. |

---

## 8. Mapowanie na fazy SKILL.md

| Faza agent-teams-builder | Currency check |
|---|---|
| Faza 1 (Planner) | TYLKO jeśli user wskazał konkretną lib — verify wersja |
| Faza 2 (spawn) | n/a |
| Faza 3 (kontrakt) | sekcja `dependencies` w kontrakcie zawiera wersje weryfikowane przez context7 |
| Faza 4 (pętla) | **OBOWIĄZKOWO przed każdym nowym importem** + breadcrumb |
| Faza 5 (pivot) | sprawdź czy poprzednie iteracje miały currency checks — brak = częsta przyczyna pivot |
| Faza 6 (verify) | `scripts/verify-library-currency.sh --all-sprints` |
| Faza 7 (ship) | część DoD |

---

## 9. Setup w projekcie

```bash
# User scope (raz na maszynę):
bash scripts/setup-context7.sh --user --api-key $CONTEXT7_API_KEY

# Project scope (per repo):
bash scripts/setup-context7.sh --project

# Test:
claude mcp list | grep context7
```

CLAUDE.md template z auto-invoke regułą: `assets/claude-md-template.md`.

---

## 10. Exit criterion

Sprint dotykający dependencies przechodzi tylko gdy:

```bash
bash scripts/verify-library-currency.sh {sprint-n}
# exit 0 + każda nowa paczka ma breadcrumb library_currency_checked
```

Brak exit 0 = blokada faza 6 verify.
