---
name: anti-rationalization
type: reference
parent: qa-architect
sources:
  - DOC/material_skill.md §3 (Anti-Rationalization Tables)
  - DOC/QA-swarm.md §3.1 (ograniczenia narracji swarmowej), §4.2 (macierz warstw), §8 (wzorce), §12.4 (macierz ryzyk)
description: Rozszerzona tabela wymówek agenta QA-architect z gotowymi ripostami z paper'a. Egzekwowana w każdej fazie przed produkcją artefaktu i przed deklaracją "blueprint complete".
---

# Anti-Rationalization Tables — qa-architect

> [!quote] material_skill.md §3
> LLM są mistrzami racjonalizacji. Tabela anty-racjonalizacji to deterministyczny hamulec — predefiniowane riposty nadrzędne wobec własnych „dobrych powodów" agenta.

## Sekcja 1 — Tabela master (15 wymówek QA)

| # | Wymówka agenta | Riposta (blokada) | Egzekwuj w fazie |
|---|---|---|---|
| 1 | „Mockujemy Postgres in-memory dla szybkości testów" | Odrzucono (paper §4.2, §8.5). Transakcje, izolacja, parameterized queries `pg`/`asyncpg`/`pgx` ≠ mock. **Testcontainers obowiązkowy** dla warstwy SQL. | Phase 2, 3, 5, 7 |
| 2 | „Wystarczy `getByTestId` — semantyczne query to overkill" | Odrzucono (paper §10.2, Testing Library Guiding Principles). Kolejność: `getByRole` → `getByLabelText` → `getByText` → `data-testid` (escape hatch). Wpływa na dostępność produktu. | Phase 3, 5 (test-author) |
| 3 | „Async Server Components testujemy w Jest, jest community plugin" | Odrzucono (paper §4.2, Next.js Testing Guide). Async RSC **nie wspierane** w Jest/Vitest oficjalnie — przesuń do Playwright e2e. | Phase 3 (Next.js), Phase 5 |
| 4 | „Jeden runner dla wszystkiego — Jest dla unit i e2e" | Odrzucono. Jest/Vitest = unit/component/integration. **Playwright = e2e** (paper §7.2). Mieszanie warstw zaciera diagnostykę. | Phase 2 |
| 5 | „GitHub Actions doda team później, na razie tylko lokalny test" | Odrzucono (paper §11). Bez CI gate = brak DoD bramki dla PR. Workflow PR (lint+typecheck+unit+integration+smoke e2e) obowiązkowy w blueprintzie. | Phase 5 (ci-author), Phase 7 |
| 6 | „MSW dla wszystkiego — łatwiej utrzymać jedną warstwę mocków" | Odrzucono (paper §8.4). Hierarchia: **MSW** = granice sieciowe; **vi.fn()/vi.spyOn() / unittest.mock** = lokalne moduły; **Testcontainers** = baza SQL. Każda warstwa ma swoją granicę mocków. | Phase 3, 5 |
| 7 | „Stack Python/Go — pomijam sekcję Server Components" | **Akceptowalne** (skip semantyczny). Każdy stack ma własny profile: załaduj `references/stack-profiles/<stack>.md`. Server Components dotyczy WYŁĄCZNIE Next.js. | Phase 0, 3 |
| 8 | „Blueprint kompletny, sprawdziłem ręcznie pliki" | Odrzucono. `sh scripts/check-blueprint-complete.sh` MUSI zwrócić exit 0 + raw output wklejony do `07-verification.md`. DoD #4 (twardy dowód). | Phase 7 |
| 9 | „Blueprint to 1500 linii, ale spójne — PR jako jedna paczka" | Odrzucono (paper §6.2 → PR Sizing). Blueprint też podlega: >300 linii diff = uzasadnienie, >1000 = split (np. config + CI + skille jako 3 PRy). | Phase 6, 8 |
| 10 | „Pominę reviewer'a, ja już zweryfikowałem" | Odrzucono. Five-Axis Review obowiązkowy w Phase 7 (paper §11 — multi-model review). Manager **nie review'uje swojej pracy** — to inny sub-agent. | Phase 7 |
| 11 | „Sub-agenty piszą do tych samych plików — dla efektywności" | Odrzucono. Manager przydziela własność plików per sub-agent (paper §13.2 — przypisanie własności). Bez tego: konflikty + niedeterministyczny output. | Phase 4 |
| 12 | „APPROVAL #1 to formalność, idę dalej" | Odrzucono. Spawn 5+ sub-agentów = koszt tokenów ×5–15 (paper §2.1, §12.1). User musi zaakceptować budżet zanim wydasz tokeny. | Phase 4 |
| 13 | „Skill `verify-tests` jest opcjonalny, projekt go nie używa" | Odrzucono (paper §6.3 — kontrakt projektowy). Skill `verify-tests` to instrukcja dla **przyszłych agentów** wchodzących do repo. Bez niego CLAUDE.md mówi „testuj", ale brak procedury. | Phase 6 |
| 14 | „Pilotaż 4-tygodniowy to overkill — wszystko zrobimy w tydzień" | Odrzucono (paper §12.3). 4 tygodnie to **minimum dla wdrożenia** wszystkich warstw + CI + supply-chain security. Skrót w tym miejscu = niedopilnowane bramki w produkcji. | Phase 8 |
| 15 | „Patchuję CLAUDE.md automatycznie — user oszczędzi czas" | Odrzucono (non-negotiable #5 + Fragile Ops). `CLAUDE.md.patch` to **patch**, nie auto-merge. APPROVAL #2 obowiązkowy. Modyfikacja kontraktu repo = decyzja usera, nie agenta. | Phase 6, 8 |

---

## Sekcja 2 — Per-faza redirects

| Faza | Wpisy do sprawdzenia |
|---|---|
| **Phase 0** | #7 (per-stack exclusions) |
| **Phase 2** | #1, #4, #6 (tooling decisions) |
| **Phase 3** | #1, #2, #3, #6 (layer strategy) |
| **Phase 4** | #11 (file ownership), #12 (approval cost) |
| **Phase 5** | #1, #2, #3, #5, #11 (sub-agent execution) |
| **Phase 6** | #9 (PR Sizing), #13 (verify-tests), #15 (patch nie auto-merge) |
| **Phase 7** | #8 (raw output skryptów), #10 (review nie self) |
| **Phase 8** | #9, #14 (pilotaż), #15 (Fragile Ops) |

---

## Sekcja 3 — Wymówki specyficzne dla orkiestracji sub-agentów

Spawn 5–6 sub-agentów = nowy obszar racjonalizacji. Te wymówki pojawiają się dopiero w Phase 4–5:

| # | Wymówka swarm | Riposta |
|---|---|---|
| S1 | „Sub-agent nie ma dostępu do Phase 2 outputu, podsumuję mu" | Sub-agent dostaje **pełny output Phase 2** w prompcie (`Read templates/configs/<stack>/...`). Podsumowanie = halucynacja źródła. |
| S2 | „Sub-agent zwrócił coś dziwnego, spróbuję jeszcze raz z innym promptem" | Stop. Sub-agent z dziwnym outputem = problem promptu lub niedoprecyzowanego scope. Popraw `prompts/<agent>.md`, nie iteruj losowo. |
| S3 | „Reviewer dał FYI severity, mogę zignorować" | FYI = nie blokuje merge, ale loguj w `07-review.md`. Ignorowanie = traci ślad audytu. |
| S4 | „Pomijam ci-author, user ma już swój GH Actions" | Odrzucono — discovery Phase 1 zweryfikowało gap. Jeśli user ma CI, ci-author **uzupełnia brakujące jobs**, nie nadpisuje. |
| S5 | „config-builder i ci-author są zależne — wywołam sekwencyjnie" | Phase 5 wprost mówi **równolegle w jednej wiadomości**. Sekwencja = ×3 czasu + brak deterministyki. Jeśli faktycznie zależność — Manager Phase 4 ma to oznaczyć. |

---

## Sekcja 4 — Wzorzec dialogu (gdy agent próbuje pójść na skróty)

> [!example] Wzorzec
> **Agent:** „Dla małej aplikacji blogowej Postgres-testcontainer to overkill. Wystarczy `pg-mem`."
>
> **Anti-rationalization response:** „Wpis #1. PostgreSQL ma własne reguły transakcyjne i izolacyjne — `pg-mem` to nie Postgres (paper §4.2, §8.5). Decyzja: Testcontainers `postgres:16-alpine` (kosztuje 3s startup, daje wierność produkcji). Logowane w `02-tooling.md` jako odrzucona alternatywa."

Format internalizowany:

```
1. Identyfikuj numer wpisu (#X lub S#).
2. Cytuj ripostę dosłownie.
3. Wykonaj wymagane działanie (bez modyfikacji).
4. Loguj w `qa-strategy.md → Anti-rationalization decisions`: "Anti-rationalization #X applied at Phase Y."
```

---

## Sekcja 5 — Anti-pattern: parafraza wymówki

| Parafraza | Standardowa wymówka |
|---|---|
| „Postgres in-memory szybszy o 80%" | #1 |
| „`data-testid` deterministyczne, semantyczne flaky" | #2 |
| „Async RSC testujemy mocking next/headers" | #3 |
| „Wszystko w Vitest, w tym browser mode" | #4 (gdy zastępuje Playwright) |
| „CI dodamy po pierwszym sprincie" | #5 |
| „MSW przy poziomie repo == single source of truth" | #6 (gdy maskuje SQL mock) |
| „Diff blueprintu spójny logicznie" | #9 |
| „Review samemu sprawdzę, oszczędzę spawn" | #10 |
| „Manualny merge CLAUDE.md, user ma terminal" | #15 |

Reguła: **gdy wątpisz, traktuj parafrazę jak standardową wymówkę** i egzekwuj ripostę.

---

## Sekcja 6 — Integracja z fazami

- **Phase 0**: Załaduj ten plik (lazy) gdy wykryty trigger qa-architect.
- **Phase 2**: Tooling-decisor MUSI wkleić w `02-tooling.md` sekcję `Anti-rationalization decisions:` listującą wymówki #1, #4, #6 i ich riposty.
- **Phase 4**: Manager MUSI wkleić wpisy S1–S5 do prompts sub-agentów.
- **Phase 5**: Każdy sub-agent dostaje constraint „przed produkcją output sprawdź anti-rationalization #X właściwy dla swojej fazy".
- **Phase 7**: Reviewer MUSI sprawdzić, czy `qa-strategy.md` zawiera `Anti-rationalization decisions` — brak = Critical finding.
- **Phase 8**: `HANDOFF.md` cytuje wymówki #14, #15 (pilotaż + auto-patch).
