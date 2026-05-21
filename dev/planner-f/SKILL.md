---
name: planner-f
description: Senior-grade workflow planowania, analizy i dokumentacji feature'a — BEZ fazy implementacji. Produkuje audytowalny pakiet planistyczny (Analysis Report + Plan z AC/DoD-spec/Thin Slices + ADR) gotowy do przekazania (handoff) skillowi wykonawczemu. Dziedziczy twarde reguły z feature-planner-v3 — Anti-Rationalization, Hyrum's Law, Chesterton's Fence, Beyoncé Rule (1:1 AC↔Test jako specyfikacja), DAMP over DRY, Thin Vertical Slices, 5 Non-negotiables. Używaj gdy zadanie brzmi „zaplanuj", „przeanalizuj i zaprojektuj", „przygotuj plan/specyfikację/ADR", „rozpisz feature przed implementacją", lub gdy user chce dokumentację decyzji bez pisania kodu. NIE używaj gdy user prosi o napisanie/zmianę kodu, testy, build, deploy lub uruchomienie.
trigger:
  - "planner-f"
  - "zaplanuj feature"
  - "przeanalizuj i zaplanuj"
  - "przygotuj plan"
  - "przygotuj specyfikację"
  - "zaprojektuj rozwiązanie"
  - "plan bez implementacji"
  - "analiza i dokumentacja"
  - "napisz ADR"
  - "/plan-f"
do-not-trigger-for:
  - "zaimplementuj X"
  - "napisz kod"
  - "popraw buga"
  - "uruchom testy / build / deploy"
  - "przeczytaj plik X"
  - "wytłumacz co robi ten kod"
  - "popraw literówkę / rename variable"
model: claude-opus-4-7
allowed-tools: ['Bash', 'Read', 'Write', 'Grep', 'Glob', 'TodoWrite']
sources:
  - dev/feature-planner-v3 (baseline — fazy 0–5 + 9)
  - DOC/material_skill.md
  - DOC/since_skill.md
version: v1.0.0
derives-from: feature-planner-v3
size-limit: 500-lines-hard
---

# planner-f — planowanie, analiza i dokumentacja (bez implementacji)

> [!important] Zakres skilla
> planner-f **planuje i dokumentuje, nie wykonuje**. Nie pisze kodu produkcyjnego, nie pisze ani nie uruchamia testów, nie robi commitów/buildów/deployów. Jedyne pliki, które tworzy/edytuje, to **artefakty planistyczne** (analiza, plan, ADR, gotchas). Gdy planowanie się kończy, pakiet jest gotowy do przekazania skillowi wykonawczemu (np. `feature-planner-v3`, `agent-teams-builder`).

> [!quote] Anti-Laziness preamble (since_skill.md §6)
> Najwyższa waga jakości analizy i planu. **Nie optymalizuj pod „szybko oddać plan".** Plan, który pomija analizę zależności albo nie ma weryfikowalnych AC, generuje rework w fazie wykonania. Każdy artefakt i każda bramka jest nienegocjowalna.

> [!important] 5 Non-negotiables (pełna treść: [non-negotiables.md](references/non-negotiables.md))
> 1. **Uwidaczniaj założenia przed planowaniem** — każde ciche założenie zgłoś, nie zgaduj.
> 2. **Zatrzymaj się przy konflikcie wymagań** — eskaluj, nie improwizuj interpretacji.
> 3. **Planuj rozwiązania nudne i oczywiste** — cleverness jest kosztem utrzymania.
> 4. **Każdy AC ma być weryfikowalny dowodem** — plan SPECYFIKUJE komendę + próg + lokalizację artefaktu (dowód zbiera wykonawca).
> 5. **Planuj tylko to, o co cię poproszono** — Scope Discipline; resztę do `out-of-scope.md`.

---

## Anti-Rationalization quick-table (pełna: [anti-rationalization.md](references/anti-rationalization.md))

Przed zapisaniem planu (Phase 4) i przed bramką akceptacji (Phase 6) — przejdź tę tabelę **explicite**, nie deklaratywnie.

| # | Wymówka agenta | Riposta (blokada) |
|---|---|---|
| 1 | „Zmiana mała, pomijam Phase 1 analizę" | Phase 1 nienegocjowalna. Min. analog + architecture walk + 5 linii kontekstu. |
| 2 | „AC jest oczywiste, opiszę słownie" | Każdy AC-F/N/C zapisany w tabeli z `Test ID` + `Komenda`. Brak = blokada Phase 6. |
| 3 | „API zmiana bezpieczna, nie ma userów" | Hyrum's Law. Każda sygnatura → `api-impact.md` z listą callerów. |
| 4 | „Proponuję usunąć martwy kod" | Chesterton's Fence. Bez `Why this existed:` (git blame) — kod ZOSTAJE w planie. |
| 5 | „Wystarczy happy path w AC" | Beyoncé Rule. Każdy edge case/failure → osobny AC z własnym testem (spec). |
| 6 | „Rozszerzę zakres, bo i tak dotykam tego modułu" | Scope Discipline. Rozszerzenie → wpis w `out-of-scope.md`, nie do planu. |
| 7 | „Plan gotowy, pomijam ADR — to formalność" | Decyzja z realnym tradeoffem (Phase 2/3) wymaga ADR. Bez ADR → Phase 6 blokuje. |
| 8 | „Anti-rationalization quick-table to formalność" | **Ta tabela to też wymówka.** Przejdź ją jawnie, cytuj numer wpisu. |

> [!note] Czego planner-f świadomie NIE egzekwuje
> Reguły wykonawcze (TDD RED-przed-implementacją, build clean, raw test logs, PR sizing przy commitach, Five-Axis code review) **nie należą do tego skilla** — egzekwuje je skill wykonawczy. planner-f je **specyfikuje** (w DoD i AC matrix), nie wykonuje.

---

## Architektura: 7 faz + 1 bramka akceptacji

| Faza | Cel | Bramka |
|---|---|---|
| 0 | Detekcja środowiska (stack / size / fragile) + Negative Triggers | — |
| 1 | Deep Analysis + Hyrum + Chesterton + gotchas | — |
| 1.5 | Dependency Impact Radius + klasyfikacja API | — |
| 2 | ≥3 hipotezy (Minimal / Idiomatic / Ambitious) | — |
| 3 | Recommendation + Hyrum Risk | — |
| 4 | Plan document (AC + DoD-spec + Thin Slices + Out-of-scope) | — |
| 5 | ADR (Architecture Decision Record) | — |
| 6 | Pakiet planistyczny + handoff | **APPROVAL** |

> [!important] Jedyna bramka jest na końcu
> planner-f kończy się jedną twardą bramką akceptacji całego pakietu (analiza + plan + ADR). Bez jawnej zgody użytkownika („zatwierdzam" / „proceed" / „ok") pakiet nie jest oznaczany jako gotowy do handoffu.

---

## Phase 0 — Detekcja środowiska

1. Sprawdź **Negative Triggers** (frontmatter `do-not-trigger-for`). Match → exit, zasugeruj właściwy tryb (np. wykonanie = `feature-planner-v3`).
2. Wykryj **stack**: `package.json` (Node), `pyproject.toml` (Python), `Cargo.toml` (Rust), `go.mod` (Go), `pom.xml`/`build.gradle` (JVM).
3. Wykryj **rozmiar** (S/M/L): `find . -type f \( -name "*.ts" -o -name "*.py" -o -name "*.rs" -o -name "*.go" \) | wc -l` + szacowany zakres zmian. Rozmiar steruje głębią analizy i liczbą slices — **nie** trybem wykonania (planner-f nie wykonuje).
4. Wykryj **Fragile Zone** — ścieżki `migrations/`, `terraform/`, `k8s/`, `auth/`, `Dockerfile`, `.github/workflows/`. Match → flag `--fragile` → plan MUSI zawierać sekcję **Rollback + Plan-Validate-Execute** (procedura dla wykonawcy).
5. Numeruj plan: `find {baseDir}/plans -name "*.md" 2>/dev/null | wc -l` + 1.

> [!warning] Output Phase 0
> `env-detection.md` z polami: stack, size, fragile, plan-number. Brak triggerów wykonawczych (ralph/teams/goal) — planner-f ich nie używa.

---

## Phase 1 — Deep Analysis

Wywołaj [analysis-protocol.md](references/analysis-protocol.md). Wymagane outputy:

1. **Stack & framework** — klasyfikacja w 1 linii.
2. **Architecture walk** — entry → routing → service → repo → DB.
3. **PRIMARY TEMPLATE (analog)** — najbliższy istniejący feature, przeczytany end-to-end. Bez analoga → Blocker Protocol (eskalacja).
4. **Data model snapshot** — tabele, relacje, indeksy, ostatnie migracje.
5. **Hyrum Impact (wstępny)** — publiczne eksporty dotknięte zmianą.
6. **Chesterton scan** — dla każdej kandydatury do usunięcia: `git blame` + `git log -L` → sekcja `Why this existed:`. Bez wyjaśnienia kod zostaje w planie.
7. **Gotchas update** — dopisz odkryte anomalia projektowe do [gotchas.md](references/gotchas.md) (template 5 pól).

> [!warning] Output Phase 1
> `analysis/<plan-id>.md`. Jeśli sekcja `Open questions` niepusta → **STOP**, zadaj pytania, czekaj na odpowiedź. Wejście w Phase 2 z otwartym pytaniem = gwarantowany rework planu.

---

## Phase 1.5 — Dependency Impact Radius + API klasyfikacja

1. Uruchom `sh {baseDir}/dev/planner-f/scripts/api-impact-scan.sh --base main`.
2. Sklasyfikuj każdy eksport: `breaking` / `additive` / `internal` (tabela w [analysis-protocol.md](references/analysis-protocol.md) §Hyrum).
3. Reverse search callerów: `git grep <symbol> -- ':!*test*'`.
4. Dla `breaking`: plan migracji callerów lub uzasadnienie w ADR.
5. **Hard gate analizy:** caller `breaking` POZA zakresem → flaga w planie + decyzja (stacking / rozszerzenie planu / eskalacja).

> [!warning] Output Phase 1.5
> `analysis/<plan-id>-api-impact.md` (jeśli zmiana publicznego API).

---

## Phase 2 — ≥3 Hipotezy

Generuj minimum 3 alternatywy:

- **Minimal** — najmniejszy ruch realizujący wymaganie.
- **Idiomatic** — zgodne z konwencją repo (preferowane domyślnie, Non-negotiable #3).
- **Ambitious** — przyszłościowe (wymaga uzasadnienia + Hyrum Risk, jeśli wybrane).

Dla każdej: trade-offs, ryzyko, koszt, Hyrum risk. Jeśli żadna hipoteza nie pokrywa wszystkich wymagań bez konfliktu → **STOP**, zapytaj (Non-negotiable #2).

---

## Phase 3 — Recommendation

1. Wybierz **jedną** hipotezę.
2. Uzasadnij wybór względem 5 Non-negotiables.
3. **Hyrum Risk section** (jeśli zmiana publiczna) — co się stanie z istniejącymi callerami.
4. Kluczowe decyzje techniczne (formaty, biblioteki, schematy) — to są kandydaci do ADR (Phase 5).

---

## Phase 4 — Plan Document

Zapisz plan w `{baseDir}/plans/<N>-<slug>.md`. Wymagane sekcje:

1. **Co i dlaczego** — 2-3 zdania, cel biznesowy.
2. **Acceptance Criteria** — tabela AC (pełen protokół: [ac-protocol.md](references/ac-protocol.md)):
   ```
   | AC-ID | Typ (F/N/C) | Priorytet (MUST/SHOULD/COULD) | Opis | Test ID | Plik testu | Komenda |
   ```
   Każdy AC ma przypisany **planowany** test (Beyoncé Rule 1:1). To **specyfikacja** — test napisze wykonawca; tu deklarujesz, czym AC będzie zweryfikowany.
3. **Definition of Done (specyfikacja dowodu)** — per AC: komenda dowodu + próg sukcesu + lokalizacja artefaktu. Pełen protokół: [dod-evidence-protocol.md](references/dod-evidence-protocol.md).
4. **Assumptions** — wszystkie założenia jawnie (Non-negotiable #1).
5. **Out of scope** — co jawnie pomijamy + uzasadnienie (Non-negotiable #5).
6. **Thin Vertical Slices** — rozbicie na end-to-end odnogi (DB→API→UI), nie warstwa-po-warstwie. Każda slice mergowalna niezależnie, z `PR size target`. Pełen protokół: [incremental-implementation.md](references/incremental-implementation.md).
7. **Rollback plan** — obowiązkowy dla `--fragile` zone (procedura Plan-Validate-Execute dla wykonawcy).
8. **Target diff size** — szacunek per slice (≤300 linii preferowane).
9. **Hyrum Risk** — jeśli zmiana publicznego API (link do `api-impact.md`).
10. **Relevant gotchas** — wskaż wpisy z [gotchas.md](references/gotchas.md) dotyczące tego feature'a.

> [!important] Anti-rationalization check
> Przed zapisaniem planu przejdź quick-table (wpisy #2, #5, #6 szczególnie). Pusty `Test ID` lub brak `Out of scope` = plan niekompletny.

---

## Phase 5 — ADR (Architecture Decision Record)

Wywołaj [adr-template.md](references/adr-template.md). Pisz ADR **tylko** gdy Phase 2/3 miały realny tradeoff (wybór technologii/wzorca kosztowny do zmiany, świadome odejście od konwencji, decyzja regulacyjna). Dla planu prosto z analoga bez tradeoffu — ADR pominięty (zaznacz „N/A — implementacja z PRIMARY TEMPLATE bez tradeoffu").

ADR MUSI zawierać:

1. **Context** — problem, ograniczenia, siły (wskaż AC-MUST/DoD, jeśli wymusiły wybór).
2. **Decision** — wybrana hipoteza, tryb oznajmujący.
3. **Consequences** — pozytywne / negatywne-koszty / operacyjne.
4. **Alternatywy rozważane** — hipotezy z Phase 2 + dlaczego odrzucone (1 zdanie każda).
5. **Anti-rationalization decisions** — wymówki, które agent odrzucił po drodze (z tabeli).
6. **Hyrum/Chesterton decisions** — zachowania API zachowane, kod nieusunięty mimo pokusy.
7. **Weryfikacja** — wskaż **planowane** testy z AC matrix (dowód zbierze wykonawca) + link do planu.

Lokalizacja: `docs/adr/ADR-<plan-id>-<slug>.md`. Długość ≤ 1 strona.

---

## Phase 6 — Pakiet planistyczny + APPROVAL GATE

> [!important] Approval checklist
> Zweryfikuj kompletność pakietu skryptem:
> `sh {baseDir}/dev/planner-f/scripts/check-plan-complete.sh --plan "$PLAN_FILE"`
>
> - [ ] `analysis/<plan-id>.md` istnieje i niepusty, `Open questions` puste.
> - [ ] `plans/<N>-<slug>.md` niepusty, wszystkie 10 sekcji obecne.
> - [ ] Każdy AC ma `Test ID` + `Komenda` (1:1 mapping, brak pustych pól).
> - [ ] DoD ma komendę dowodu + próg + lokalizację dla każdego AC.
> - [ ] `Out of scope` obecne i niepuste.
> - [ ] ≥1 Thin Vertical Slice, żadna >300 linii target bez uzasadnienia.
> - [ ] Jeśli `--fragile`: sekcja Rollback + Plan-Validate-Execute obecna.
> - [ ] ADR obecny **lub** jawne „N/A" z uzasadnieniem.
>
> **STOP — czekaj na jawną zgodę użytkownika.** Pakiet oznaczasz „gotowy do handoffu" dopiero po „zatwierdzam" / „proceed" / „ok".

### Handoff

Po akceptacji wypisz **podsumowanie handoff** dla skilla wykonawczego:

```
Pakiet planistyczny gotowy:
- Analiza:  analysis/<plan-id>.md
- Plan:     plans/<N>-<slug>.md  (X slices, Y AC)
- ADR:      docs/adr/ADR-<plan-id>-<slug>.md  [lub N/A]
- API impact: analysis/<plan-id>-api-impact.md  [jeśli dotyczy]

Sugerowany wykonawca: feature-planner-v3 (Phase 6+) / agent-teams-builder.
planner-f NIE implementuje — przekaż plan do wykonania.
```

---

## Indeks referencji

### Protokoły procesowe

- [non-negotiables.md](references/non-negotiables.md) — 5 zasad master (wersja planistyczna).
- [anti-rationalization.md](references/anti-rationalization.md) — tabela wymówek (rzędy planistyczne).
- [analysis-protocol.md](references/analysis-protocol.md) — Phase 1 (+ Hyrum + Chesterton).
- [ac-protocol.md](references/ac-protocol.md) — AC (F/T/N) + Beyoncé 1:1 jako specyfikacja.
- [dod-evidence-protocol.md](references/dod-evidence-protocol.md) — formaty dowodów do zadeklarowania w planie.
- [incremental-implementation.md](references/incremental-implementation.md) — Thin Vertical Slices (rozbicie w planie).
- [gotchas.md](references/gotchas.md) — auto-narastająca baza anomalii projektowych.

### Szablon

- [adr-template.md](references/adr-template.md) — ADR (bez sekcji wykonawczych).

### Skrypty

- `scripts/api-impact-scan.sh` — Hyrum risk scan (Phase 1.5).
- `scripts/check-plan-complete.sh` — bramka kompletności pakietu (Phase 6).

---

## Sources

- [dev/feature-planner-v3/SKILL.md](../feature-planner-v3/SKILL.md) — baseline (fazy 0–5 analizy/planu + Phase 9 ADR). planner-f odcina fazy wykonawcze (6 implementacja, 6.5 Prove-It, 7 testy, 7.8 preview, 8 review, /goal loop).
- [DOC/material_skill.md](../../DOC/material_skill.md) — pryncypia procesowe (Anti-rationalization, DoD, Scope Discipline, Hyrum, Chesterton, Beyoncé).
- [DOC/since_skill.md](../../DOC/since_skill.md) — pryncypia projektowe (token budget, kebab-case, imperatyw, scripts/, Negative Triggers, Anti-Laziness, Thin Vertical Slices).
