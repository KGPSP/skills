---
title: Czytanie traces — kalibracja uprzęży Agent Teams po realnych przebiegach
load-when: "Po 3+ rzeczywistych przebiegach skilla — kalibracja punktowa, nie ogólna"
source:
  - DOC/agent-teams-generator-ewaluator.md §8 (Optymalizacja i utrzymanie)
  - DOC/since_skill.md §6 (Calibration loop)
---

# Czytanie traces — sekretny sos kalibracji

> Kalibracja uprzęży **nie da się zautomatyzować**. Klucz to żmudne, ręczne czytanie surowych logów konwersacji agentów linijka po linijce. Tylko tak dostrzeżesz, gdzie osąd modelu rozjechał się z ludzkim.

---

## 1. Kiedy czytać traces

- Po **każdym** zakończonym `/goal` (nawet udanym — patrz §3 fałszywe sukcesy).
- Po każdym pivocie (czy uzasadniony?).
- Po każdej eskalacji do human (czy konflikt był rzeczywisty?).
- Co 5-10 sesji — globalny audit (czy uprząż dryfuje?).

Wpis w kalendarzu: "Czytanie traces sesji X" = 30-60 min ręcznej pracy. Bez tego skill stoi.

---

## 2. Co czytać

### 2.1 `state/breadcrumbs.json` — chronologia zdarzeń

```bash
jq '.[] | "\(.ts) [\(.actor)] \(.event): \(.details)"' state/breadcrumbs.json
```

Szukaj wzorców:

- **Iteracje bez progresu** — `iteration_verdict` z tym samym `passed/total` 2+ razy. Co Evaluator mówił? Co Generator zmieniał?
- **Pivoty** — jakie kryterium było "fatal"? Czy można było je przewidzieć w fazie 3?
- **Eskalacje** — jaki konflikt? Czy mógł być uniknięty przez lepszy kontrakt?
- **Długie luki czasowe** między eventami — agent się zacinał? Tool timeout?

### 2.2 `state/contracts/sprint-{n}.json` — dialog negocjacji

Czytaj sekwencję `evaluator_review` ↔ `generator_response`:

- Czy Evaluator daje **konstruktywną** krytykę, czy generyczną ("za słabe testy")?
- Czy Generator **odpiera** kryteria z uzasadnieniem, czy biernie akceptuje?
- Ile iteracji do konwergencji? <3 = za łatwo, >7 = za ciężko.

### 2.3 `state/evidence/sprint-{n}/*.metadata.json` — dowody

```bash
jq '.[] | select(.passed == true) | {criterion: .criterion_id, observation}' \
  state/evidence/sprint-2/*.metadata.json
```

- Czy `observation` jest konkretne ("kursor przesuwa się o 32px") czy generyczne ("działa")?
- Czy są fałszywe sukcesy? (patrz §3).

---

## 3. Fałszywe sukcesy — co je zdradza

Najczęstsza patologia: Evaluator zaakceptował coś, co nie powinno przejść.

### 3.1 Sygnały

| Sygnał w trace | Interpretacja |
|---|---|
| `observation: "wygląda dobrze"` zamiast konkretu | Evaluator polega na intuicji |
| `observation` powtarza dosłownie kryterium | Brak weryfikacji, copy-paste |
| `iteration_verdict.passed` skoczyło z 10/15 do 15/15 w 1 iteracji | Generator wymusił lub Evaluator pochopnie zaakceptował |
| Brak `evidence_path` przy `passed: true` | Nieautoryzowany passed (walidator powinien zatrzymać) |
| Te same `failed_criteria` 3 iteracje z rzędu, potem nagle `passed` | Czy faktycznie naprawione, czy odpuszczone? |
| Sprint zamknięty bez `playwright` ani `chrome` w `tool` metadata | Brak runtime testów, tylko build |

### 3.2 Reakcja

Po wykryciu fałszywego sukcesu:

1. Dopisz **konkretną wymówkę** do `anti-rationalization.md` z ripostą.
2. Dopisz **konkretne kryterium walidatora** (np. `observation` musi mieć liczbę lub literał z UI).
3. Zaktualizuj `evaluator-rubric.md → §2.4 Twarde progi binarne` z dodatkowym przykładem.
4. CHANGELOG: `fix: tighten evaluator verification for {pattern}`.

**NIE** dodawaj ogólnej instrukcji "Evaluator musi być bardziej krytyczny". To jest do zignorowania.

---

## 4. Wzorce z dokumentu źródłowego (§8)

> "Sekret kalibracji nie jest w sprytnym prompcie, tylko w czytaniu logów (traces)."

### Procedura kalibracji punktowej

1. Odpal skill na **3-5 realnych zadaniach** z domeny.
2. **Przeczytaj surowe traces linijka po linijce** — gdzie model się rozjechał z twoim osądem?
3. **Doprecyzuj prompt/rubrykę** w **miejscu rozjazdu**, nie ogólnie.
4. **Powtórz** na 3-5 nowych zadaniach.

### Anti-pattern: ogólne instrukcje

| ❌ Złe | ✅ Dobre |
|---|---|
| "Evaluator powinien być rygorystyczny" | "Kryterium typu 'design' wymaga `observation` z konkretnym kolorem hex i nazwą czcionki" |
| "Generator powinien lepiej testować" | "Każdy `keyboard.press` w komponencie ma odpowiadający test w `*.spec.ts` z `expect(...).toBe(...)`" |
| "Pivot ma być uzasadniony" | "Pivot wymaga `pivot_plan.md` z listą `failed_criteria` ≥3 z 2 ostatnich iteracji" |

---

## 5. "Empatia do modelu" — wczucie się w buty agenta

Inżynierowie Anthropic nazywają to "wyrabianiem empatii do modelu" — wchodzeniem w jego buty, żeby zrozumieć tok rozumowania.

### Pytania, które warto sobie zadać przy czytaniu trace:

1. **Co model widział w kontekście w tym momencie?** Czy miał dostęp do kontraktu? Czy plan był wstrzyknięty?
2. **Jakie "logiczne wymówki" mógł zaakceptować?** Czy moja tabela anti-rationalization je pokrywa?
3. **Czy model wiedział, kiedy spauzować?** Czy procedura ma wyraźny `STOP` w tym miejscu?
4. **Czy model miał wybór?** Może procedura wymusza złą decyzję strukturalnie?

Każda odpowiedź "model nie wiedział" / "model nie miał wyboru" → poprawka w SKILL.md lub references/.

---

## 6. Metryki ilościowe (zalecane do śledzenia)

Po każdej sesji wpisz do `state/metrics.json` (NIE markdown — append-only):

```json
{
  "session_id": "...",
  "ts_start": "...",
  "ts_end": "...",
  "duration_min": 342,
  "sprints_completed": 3,
  "sprints_pivoted": 1,
  "total_iterations": 19,
  "avg_iterations_per_sprint": 6.3,
  "evidence_files": 47,
  "escalations": 0,
  "false_successes_found_in_review": 2,
  "cost_estimate_usd": 23.45
}
```

Trend: jeśli `false_successes_found_in_review` rośnie → uprząż dryfuje, podkręć rubryki.

---

## 7. Read traces jako obowiązkowy etap

W procesie:

| Faza | Read traces? |
|---|---|
| 0 — bootstrap | nie |
| 1-5 — pętla | nie (w trakcie sesji) |
| 6 — verify | nie |
| 7 — ship | nie |
| **POST-SESJA** | **TAK — obowiązkowo dla pierwszych 10 sesji** |

Pierwsze 10 sesji = full audit traces (60 min każda). Potem co 5. sesja LUB po każdym pivocie.

**Bez tego skill nie poprawia się.** "Skill napisany raz" = "skill, który dryfuje".

---

## 8. Wzorzec: skill changelog

Każda zmiana z czytania traces ma wpis w CHANGELOG:

```markdown
## [v1.2.0] — 2026-06-15

### Fixed (from traces session #7)
- Evaluator akceptował `passed: true` bez `observation` zawierającego liczbę.
  Riposta: dopisałem do anti-rationalization.md §2.2 oraz w evaluator-rubric.md §2.4.
- Generator pomijał `state/breadcrumbs.json` w trakcie szybkich iteracji.
  Riposta: dopisałem walidator `check-breadcrumbs-append-only.sh` do exit criterion fazy 4.

### Changed (from traces session #8)
- MAX_ITERATIONS z 5 do 7 — sessions #5-8 pokazały że 5 iteracji za mało dla sprintów >300 linii.
```

Bez CHANGELOG zmiany **wracają** (regresja kalibracji).
