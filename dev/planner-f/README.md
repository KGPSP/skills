# planner-f

> Senior-grade workflow **planowania, analizy i dokumentacji** feature-a — **bez fazy implementacji**. 7 faz, 1 bramka akceptacji. Produkuje audytowalny pakiet planistyczny (Analysis Report + Plan z AC/DoD-spec/Thin Slices + ADR) gotowy do przekazania skillowi wykonawczemu.

[![version](https://img.shields.io/badge/version-v1.0.0-blue)]() [![derives-from](https://img.shields.io/badge/derives--from-feature--planner--v3-lightgrey)]() [![scope](https://img.shields.io/badge/scope-planning_only-orange)]()

---

## Co to jest

`planner-f` to skill dla Claude Code, który prowadzi agenta przez **audytowalny proces planowania** — od deep analysis, przez ≥3 hipotezy i rekomendację, po kompletny plan z weryfikowalnymi AC oraz ADR. **Tu się zatrzymuje.** Nie pisze kodu produkcyjnego, nie pisze ani nie uruchamia testów, nie robi commitów/buildów/deployów.

To wariant `audited-feature-workflow` odcięty od faz wykonawczych. Idea: oddzielić **„co i dlaczego budujemy"** (planner-f) od **„budujemy"** (wykonawca). Plan, który powstaje, jest na tyle precyzyjny, że dowolny skill wykonawczy (lub człowiek) może go zrealizować bez zgadywania.

## Kiedy używać

✅ **TAK** — gdy:
- Chcesz analizę i plan **przed** dotknięciem kodu.
- Potrzebujesz dokumentacji decyzji (ADR), specyfikacji AC, rozbicia na slices.
- Delegujesz wykonanie osobno (inny skill, inny agent, inny człowiek) i chcesz audytowalny handoff.
- Zadanie ma impact architektoniczny i warto najpierw rozważyć alternatywy.

❌ **NIE** — gdy:
- Prosisz o napisanie/zmianę kodu, testy, build, deploy → użyj `audited-feature-workflow`.
- Jednoliniowa poprawka, literówka, rename.
- Czysto deklaratywne pytanie („wytłumacz co robi ten kod").

Pełna lista negatywnych triggerów w [SKILL.md `do-not-trigger-for`](SKILL.md).

## Jak uruchomić

W prompcie do Claude Code napisz np.:

```
planner-f, zaplanuj <nazwa feature>
```

lub jeden z innych triggerów: `przeanalizuj i zaplanuj`, `przygotuj plan`, `przygotuj specyfikację`, `zaprojektuj rozwiązanie`, `plan bez implementacji`, `napisz ADR`, `/plan-f`.

Claude rozpozna trigger, wykona Phase 0 (env detection) i poprowadzi przez 7 faz do bramki akceptacji.

## Architektura — 7 faz, 1 bramka

| Faza | Cel | Bramka |
|------|-----|--------|
| 0 | Env detection (stack/size/fragile) + Negative Triggers | — |
| 1 | Deep analysis + Hyrum + Chesterton + gotchas | — |
| 1.5 | Dependency Impact Radius + API klasyfikacja | — |
| 2 | ≥3 hipotezy (Minimal / Idiomatic / Ambitious) | — |
| 3 | Recommendation + Hyrum Risk | — |
| 4 | Plan document (AC + DoD-spec + Thin Slices + Out-of-scope) | — |
| 5 | ADR (Architecture Decision Record) | — |
| **6** | **Pakiet planistyczny + handoff** | **APPROVAL** |

## Czym się różni od audited-feature-workflow

| | audited-feature-workflow | planner-f |
|---|---|---|
| Zakres | analiza + plan + **implementacja + testy + review** | analiza + plan + dokumentacja |
| Fazy | 16 (+ /goal) | 7 |
| Bramki approval | 6 | 1 (na końcu) |
| Pisze kod / testy | TAK | **NIE** |
| Tryby ralph/teams/goal | TAK | NIE |
| Hyrum + Chesterton | TAK | TAK (zachowane) |
| AC ↔ Test (Beyoncé) | egzekwuje wykonanie testów | egzekwuje **specyfikację** testów |
| DoD evidence | zbiera raw artefakty | **specyfikuje** format dowodu |
| Output końcowy | zmergowany feature + ADR | **pakiet planistyczny do handoffu** |

planner-f i audited-feature-workflow są komplementarne: planner-f wytwarza plan, audited-feature-workflow (od Phase 6) go realizuje.

## Co planner-f świadomie NIE robi

Reguły wykonawcze dziedziczone z v3 — TDD RED-przed-implementacją, build clean, raw test logs, PR sizing przy commitach, Five-Axis code review, live UI preview, ralph/teams/goal loop — **nie należą do tego skilla**. planner-f je **specyfikuje** w planie (matryca AC, DoD), a egzekwuje skill wykonawczy. Skrypty `extract-raw-log.sh`, `check-ac-coverage.sh`, `verify-build-clean.sh` z v3 nie są tu dołączone (są po stronie wykonawcy).

## Struktura

```
planner-f/
├── SKILL.md                       # 7 faz + bramka akceptacji
├── README.md
├── CHANGELOG.md
├── references/
│   ├── non-negotiables.md         # 5 zasad (wersja planistyczna)
│   ├── anti-rationalization.md    # 11 wierszy (tylko planistyczne)
│   ├── analysis-protocol.md       # Phase 1 (+ Hyrum + Chesterton)
│   ├── ac-protocol.md             # AC F/T/N + Beyoncé jako spec
│   ├── dod-evidence-protocol.md   # formaty dowodu do zadeklarowania
│   ├── incremental-implementation.md  # Thin Vertical Slices
│   ├── adr-template.md            # ADR (bez sekcji wykonawczych)
│   └── gotchas.md                 # auto-narastająca baza anomalii
├── scripts/
│   ├── api-impact-scan.sh         # Hyrum risk scan (Phase 1.5)
│   └── check-plan-complete.sh     # bramka kompletności (Phase 6)
└── tests/fixtures/
    ├── complete-plan.md           # fixture pozytywny (gate exit 0)
    └── incomplete-plan.md         # fixture negatywny (gate exit 1)
```

## Artefakty wyjściowe

- `analysis/<plan-id>.md` — Analysis Report (stack, architektura, analog, impact radius, Hyrum/Chesterton).
- `analysis/<plan-id>-api-impact.md` — lista callerów dla zmian publicznego API (jeśli dotyczy).
- `plans/<N>-<slug>.md` — plan z AC matrix, DoD-spec, Thin Slices, Out-of-scope, Rollback.
- `docs/adr/ADR-<plan-id>-<slug>.md` — decyzja architektoniczna (lub jawne „N/A").

Po akceptacji skill wypisuje podsumowanie handoff dla skilla wykonawczego.

## Źródła

Dziedziczy z [`audited-feature-workflow`](../audited-feature-workflow) (fazy 0–5 + ADR) oraz `DOC/material_skill.md` i `DOC/since_skill.md`.
