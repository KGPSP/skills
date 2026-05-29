---
title: "DOC — korpus kanoniczny pryncypiów KG PSP Skills"
type: index
status: kanoniczny
version: v2
audience: autorzy i agenci pracujący nad skillami w tym repo
tags: [doc, index, canonical, agent-skills, kg-psp]
updated: 2026-05-29
---

# DOC — korpus kanoniczny

> **Typ:** index · **Status:** kanoniczny · **Aktualizacja:** 2026-05-29
> **Zasada nr 1 (CLAUDE.md):** przed pracą nad jakimkolwiek skillem przeczytaj ten katalog.

## Streszczenie

`DOC/` to **źródło prawdy** dla metodyki skilli w repozytorium. Każdy dokument ma charakter paperu (blok metadanych, streszczenie, słowa kluczowe, spis treści). Pola `sources:`/`source:` w skillach wskazują na `DOC/...` i są kontraktem audytowalności — **nie zmieniaj nazw plików ani numeracji sekcji (§N)**.

**Słowa kluczowe:** pryncypia · Process over Prose · pięć filarów · Progressive Disclosure · Agent Teams · /goal · QA swarm · `source:` traceability.

## Katalog dokumentów

| Plik | Typ | Status | Rola | Cytowany w (plikach skilli) |
|------|-----|--------|------|------------------------------|
| [`material_skill.md`](material_skill.md) | explanation | kanoniczny | Zwarta esencja pryncypiów procesowych (§1–§10) | 78 |
| [`since_skill.md`](since_skill.md) | research-report | kanoniczny | Pełny raport: pięć filarów, SDLC, code review (§1–§8) | 67 |
| [`INSTRUKCJA-BUDOWANIA-SKILLI.md`](INSTRUKCJA-BUDOWANIA-SKILLI.md) | guide | kanoniczny | Procedura autorska krok-po-kroku (§0–§11) | 25 |
| [`agent-teams-generator-ewaluator.md`](agent-teams-generator-ewaluator.md) | methodology | kanoniczny | Wzorzec Generator–Ewaluator (§1–§10) | 28 |
| [`goal_mode.md`](goal_mode.md) | reference | kanoniczny | Wzorzec polecenia `/goal` | 10 |
| [`QA-swarm.md`](QA-swarm.md) | methodology | kanoniczny | Wieloagentowa metodyka QA dla React/Next.js/Node/PostgreSQL (§1–§14) | 20 |
| [`agents_swarm.md`](agents_swarm.md) | research-report | kanoniczny | Warstwa koordynacji + SwarmNode Factory (§1–§6) | 3 |
| [`dynamic_workflows-cc.md`](dynamic_workflows-cc.md) | research-report | kanoniczny | Kompendium orkiestracji Dynamic Workflows w Claude Code v2.1.154+ (§1–§14) | — |
| [`Messages_API_w_Opus_4.8.md`](Messages_API_w_Opus_4.8.md) | research-report | kanoniczny | Przegląd Messages API w Opus 4.8 i śródsesyjnych komunikatów systemowych (§1–§10) | — |
| [`agenci-ai-2026-przeglad-ekosystemu.md`](agenci-ai-2026-przeglad-ekosystemu.md) | research-report | tło teoretyczne | Szeroki przegląd ekosystemu agentowego AI (poglądowy) | — |
| [`GEO-SEO.md`](GEO-SEO.md) | — | placeholder | Zarezerwowany na przyszłą notatkę (obecnie pusty) | — |


## Kolejność czytania (dla autora skilla)

1. [`INSTRUKCJA-BUDOWANIA-SKILLI.md`](INSTRUKCJA-BUDOWANIA-SKILLI.md) — jak budować skill: struktura, szablon, checklista §9, reguła `source:` §10.
2. [`material_skill.md`](material_skill.md) — pryncypia procesowe (Process over Prose, Anti-Rationalization, DoD, Google DNA, 5 Non-negotiables).
3. [`since_skill.md`](since_skill.md) — pryncypia projektowe (token budget, kebab-case, Negative Triggers, Thin Vertical Slices, Prove-It).
4. Warunkowo: [`goal_mode.md`](goal_mode.md) (tryb `/goal`), [`agent-teams-generator-ewaluator.md`](agent-teams-generator-ewaluator.md) (orkiestracja sub-agentów), [`QA-swarm.md`](QA-swarm.md) (skille QA dla stacku React/Next/Node/PostgreSQL), [`agents_swarm.md`](agents_swarm.md) (warstwa koordynacji wieloagentowej).

## Konwencje korpusu

- **Każdy dokument = paper:** front matter (`title`, `type`, `status`, `version`, `updated`, `tags`), blockquote header (`> **Typ:** … · **Status:** … · **Aktualizacja:** …`), sekcja Streszczenie, Słowa kluczowe, Spis treści.
- **Stabilność cytowań:** nazwy plików i numery sekcji (§N) są kontraktem — zmiana psuje pola `source:` w skillach. Numeracja nietykalna.
- **Status:** `kanoniczny` (źródło prawdy, cytowane), `tło teoretyczne` (poglądowe), `placeholder` (zarezerwowany), `archiwalny` (historyczne).
- **Wersjonowanie:** plik `v1`, `v2`… w `version:` — większa zmiana semantyczna podbija wersję; aktualizacja czysto kosmetyczna — tylko `updated:`.
