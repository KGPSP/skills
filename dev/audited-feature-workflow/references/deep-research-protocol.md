---
name: deep-research-protocol
type: reference
parent: audited-feature-workflow
sources:
  - "dev/replit-style-workflow/SKILL.md (Phase 1.0 — Deep research probe; stock CC + pluginy, ZERO Gemini)"
  - DOC/material_skill.md §6 — Grounding in Real Expertise (skill uzupelnia luki, nie powtarza wiedzy modelu)
  - DOC/since_skill.md §6 — Anti-Laziness + equipment lock
  - "https://code.claude.com/docs/en/model-config"
description: Phase 1.0 — Deep Research Probe. Decyduje czy feature wymaga researchu i czym go zrobic (stock Claude Code + pluginy, ZERO zewnetrznych LLM). context7 OBLIGATORYJNY przed implementacja kazdej zewn. biblioteki. Laduj na starcie Phase 1 (po Phase 0), zwlaszcza gdy request dotyka zewn. biblioteki/API/regulacji.
---

# Deep Research Protocol — Phase 1.0 (start Phase 1, przed deep analysis)

> [!important] Cel pliku
> Agent domyslnie pisze kod z pamieci (training data) — to halucynacja API. Ten protokol wymusza **ugruntowanie w aktualnych zrodlach** PRZED analiza i implementacja. Research to **paliwo dla planu**, nie cel sam w sobie. Zasada nadrzedna: *skill uzupelnia luki, nie powtarza ogolnej wiedzy modelu* (material_skill.md §6).

## Kiedy

- **Start Phase 1**, przed krokiem 1.1 (stack detection) z [analysis-protocol.md](analysis-protocol.md).
- **Skip calkowicie** dozwolony **tylko** gdy SPELNIONE LACZNIE: rozmiar = **S** AND analog feature znany w repo AND zero nowych zaleznosci / zewn. API / regulacji.
- Inaczej research jest **obowiazkowy**.

## Equipment lock (twarda reguła)

- **Wylacznie stock Claude Code + pluginy.** ZERO zewnetrznych LLM — zakaz `delegate-gemini` i analogow.
- **Maks 2 mechanizmy** w jednym Phase 1 — research nie jest celem, tylko paliwem dla planu.

## Mechanizmy — mapowanie sygnal → narzedzie

| Sygnal w requeście | Mechanizm | Trigger |
|---|---|---|
| **JAKAKOLWIEK** zewn. biblioteka / API biblioteki / migracja wersji (React, Next, Prisma, Tailwind, Drizzle, …) | **`context7`** (resolve-library-id → query-docs) — **OBLIGATORYJNE przed implementacja** | Zawsze przed napisaniem kodu uzywajacego biblioteki — nie polegaj na pamieci / training data |
| „Jak my to robimy" — nieznany obszar repo / wiele kandydatow na analog | **`Agent` z `subagent_type=Explore`** (1–3 rownolegle) | Gdy `rg`/`grep` w 1.3 daje > 20 hitow lub 0 |
| Konkretny URL ze specyfikacja / PRD / dokumentem urzedowym | **`defuddle`** | Czysty markdown z URL (zamiast WebFetch z noise'em) |
| Ogolny research bez znanego URL (regulacja, standard, RFC) | **`WebSearch`** → potem `defuddle`/`WebFetch` na top-3 | Domena prawna/proceduralna (PSP, RODO, WCAG) i brak materialu lokalnie |
| Gleboka analiza istniejacego kodu (security, dependency graph, „co to robi") | **`codex:rescue`** | Kod legacy > 500 linii bez testow, lub feature dotykajacy auth/permissions |

## context7 — obligatoryjny przed implementacja

- Dla **kazdej** zewn. biblioteki, ktorej feature uzywa: `resolve-library-id` → `query-docs` dla konkretnego API/wzorca **PRZED** napisaniem kodu (Phase 6).
- Wynik loguj jako `context7: <lib>@<ver> — <obszar>` (np. `context7: prisma@5 — relations + transaction API`).
- Anti-Rationalization: *„znam to API z pamieci"* → **Odrzucono.** Training data driftuje; docs sa zrodlem prawdy. Bez wpisu `context7:` przy zewn. bibliotece — Gate Phase 1.0 zamkniety (uruchom z `--require-context7`).

## Output (dowód) + Gate

Wpisz w Analysis Report (`analysis/<plan-id>.md`) sekcje:

```markdown
## Research used
- context7: react@19 — server-actions
- Explore: app/(auth)/ patterns
```

Skip dozwolony tylko z uzasadnieniem:

```markdown
## Research used
- none — feature S, analog znany w repo, zero zewn. zaleznosci
```

**Gate Phase 1.0:**

```sh
sh {baseDir}/dev/audited-feature-workflow/scripts/check-research-log.sh --file analysis/<plan-id>.md
# gdy Phase 1.1 wykryla zewn. biblioteke:
sh {baseDir}/dev/audited-feature-workflow/scripts/check-research-log.sh --file analysis/<plan-id>.md --require-context7
```

Skrypt egzekwuje (deterministycznie): sekcja `## Research used` istnieje i niepusta · skip = `none` ma uzasadnienie · research zadeklarowany nazywa mechanizm (`context7`/`Explore`/`defuddle`/`WebSearch`/`WebFetch`/`codex`) · z `--require-context7` musi byc wpis `context7:`. exit 0 = pass, exit 1 = blokada.

## Anti-Rationalization — research laziness

| Wymowka agenta | Riposta (blokada) |
|---|---|
| „Znam to API z pamieci, context7 zbedny" | Odrzucono. Training data driftuje. `context7:` obowiazkowy przed kodem uzywajacym biblioteki. |
| „To S, pomijam research" | Skip wymaga 3 warunkow LACZNIE (S AND analog AND zero zewn.). Zapisz `none — <powod>`, nie pustke. |
| „Zrobie research w trakcie implementacji" | Research = paliwo dla PLANU. Po Phase 1.0 plan stoi na faktach, nie domyslach. |
| „Uzyje Gemini, szybciej" | Equipment lock. ZERO zewn. LLM. Stock CC + pluginy only. |
| „Wrzuce 5 mechanizmow naraz" | Maks 2/Phase 1. Research to nie cel — to wejscie do hipotez. |

## Reguła ładowania (Progressive Disclosure)

Laduj gdy: start Phase 1 i request zawiera sygnal zewn. biblioteki/API/migracji/regulacji, LUB rozmiar > S, LUB brak znanego analoga w repo. Dla **S z analogiem i zero zewn. zaleznosci** — pomin (zapisz `none — …` i przejdz do 1.1).

## Sources

- [dev/replit-style-workflow/SKILL.md](../../replit-style-workflow/SKILL.md) — Phase 1.0 Deep research probe (wzorzec rodzica; equipment lock, tabela mechanizmow, `## Research used`).
- [analysis-protocol.md](analysis-protocol.md) — Phase 1 deep analysis; sekcja `## Research used` w szablonie raportu.
- [dynamic-workflows-standard.md](dynamic-workflows-standard.md) — gdy research obejmuje > 5 rownoleglych sciezek → fan-out czytelnikow (DOC §3).
- [DOC/material_skill.md](../../../DOC/material_skill.md) §6 — Grounding in Real Expertise.
