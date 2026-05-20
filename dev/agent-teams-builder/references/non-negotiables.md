---
title: 5 Non-negotiables — zasady niepodlegające negocjacjom dla zespołu agentów
load-when: "Konflikt wymagań LUB eskalacja LUB Generator/Evaluator zgłasza wątpliwość"
source:
  - DOC/material_skill.md §8 (Pięć Zasad Niepodlegających Negocjacjom)
  - DOC/since_skill.md §2 (Pięć filarów)
---

# 5 Non-negotiables w kontekście Agent Teams

> Pięć zasad niepodlegających negocjacjom (Non-negotiables) z material_skill.md §8. Tu — z konkretną interpretacją operacyjną dla zespołu Generator-Evaluator.

---

## 1. Uwidaczniaj założenia przed budowaniem

**Reguła:** każde ciche założenie musi być zgłoszone w `state/plan.md → Open Questions` LUB w kontrakcie sprintu → `assumptions: [...]`.

### Operacyjnie

- **Planner:** sekcja `Open Questions` w `state/plan.md` jest obowiązkowa. Pusta lista = sygnał ostrzegawczy (Planner założył coś bez świadomości).
- **Generator:** przed implementacją kryterium z niejasnym `check`, dopisz `assumption` w breadcrumbs: `{"actor": "generator", "event": "assumption_declared", "details": "Zakładam, że timeout API to 5s — nie ma tego w kontrakcie."}`.
- **Evaluator:** weryfikuj wg kontraktu, NIE wg własnych założeń. Jeśli kryterium jest niejasne — `verdict: "ambiguous_criterion"`, eskalacja, NIE pochopne `passed: true`.

### Anty-wzorzec

> Generator pisze: "zakładam że X" → implementuje → Evaluator dostaje produkt z założeniem, którego nie zna → fail.

**Riposta:** każde "zakładam" w trakcie pętli = pause + breadcrumb + amendment kontraktu LUB eskalacja.

---

## 2. Zatrzymaj się przy konflikcie wymagań

**Reguła:** ZAKAZ zgadywania intencji. Konflikt = STOP → `state/blockers.md` → human.

### Operacyjnie

Sygnały konfliktu:

- Kontrakt mówi A, plan mówi B.
- Feedback Evaluatora przeczy poprzedniemu feedback'owi.
- Smoke test przeczy specyfikacji.
- Dwa kryteria są wzajemnie wykluczające.

### Procedura STOP

1. Generator/Evaluator zapisuje `state/blockers.md`:

```markdown
# Blocker — 2026-05-19T18:30

## Rola zgłaszająca
generator (sprint-3, iteration 4)

## Sprzeczność
Kontrakt C-12: "wszystkie API zwracają JSON".
Kontrakt C-18: "endpoint /download zwraca application/octet-stream".

## Co próbowałem
- Reinterpretacja: "JSON dla błędów, binary dla success" — brak potwierdzenia w kontrakcie.
- Sprawdziłem plan.md — brak wyjaśnienia.

## Eskalacja do human
Wymagana decyzja: dopisać amendment do kontraktu LUB renegocjacja sprintu.
```

2. Breadcrumb: `{"event": "escalation", "blocker_path": "state/blockers.md"}`.
3. **Sesja pauzowana.** Generator NIE pisze kodu. Evaluator NIE ocenia.
4. Human dopisuje decyzję w `state/blockers.md → Resolution`, breadcrumb `{"event": "blocker_resolved"}`.
5. Pętla wznawiana z amendments kontraktu.

### Anty-wzorzec

> Generator: "wybiorę interpretację A, jest bardziej zgodna z duchem projektu" → implementuje → Evaluator weryfikuje wg interpretacji B → 4 iteracje stracone.

**Riposta:** brak "ducha projektu" w kontrakcie. Tylko twarde kryteria.

---

## 3. Wybieraj rozwiązania nudne i oczywiste

**Reguła:** *Cleverness is expensive.* Kod ma być czytelny dla najsłabszego ogniwa zespołu (= przyszły agent recoverujący sesję LUB human review rano).

### Operacyjnie

| Decyzja | Wybór nudny | Wybór sprytny |
|---|---|---|
| Walidacja | `zod` / `joi` | Custom recursive parser |
| State management | `useState` / lokalny store | Custom event emitter z RxJS |
| API client | `fetch` + retry decorator | Generator-based interceptor chain |
| Storage | `sqlite` / JSON file | In-memory graph database |
| Routing | `react-router` / `next/router` | Custom history API z deep linking |

**Wybór nudny wygrywa** chyba że kontrakt jawnie wymaga inaczej (rzadkie).

### Sygnały sprytności (red flags)

- Plik `<Name>Factory<Pattern>Adapter.ts` z 4 warstwami abstrakcji.
- Komentarz: `// elegant solution using monadic composition`.
- Generic na 5+ parametrów typu.
- Eval / Function constructor / dynamic import w gorącej ścieżce.

**Riposta Evaluatora:** kryterium `craft.simplicity` → `passed: false`. Generator refaktoruje na nudne.

---

## 4. Dostarczaj twardy dowód, nie deklarację

**Reguła:** każdy status `done` musi być podparty artefaktem.

### Operacyjne dowody (kolejność preferencji)

1. **Surowy output testu** — `Tests: 12 passed, 0 failed`.
2. **Czysty build** — `npm run build` exit 0, `0 warnings`.
3. **Playwright screenshot** + trace zachowania.
4. **Chrome DevTools trace** — network, console, performance.
5. **Computer Use screenshot** — dla aplikacji desktopowych.
6. **curl output** + status code dla API.

### Co NIE jest dowodem

| Zła deklaracja | Co jest źle |
|---|---|
| „Działa lokalnie u mnie" | Brak artefaktu reprodukcyjnego |
| „Powinno przejść" | Spekulacja |
| „Z mojej analizy wynika, że..." | Wewnętrzne rozumowanie |
| „Wszystkie testy zielone" (bez wklejenia outputu) | Brak surowego logu |

### Lokalizacja dowodów

Wszystko w `state/evidence/sprint-{n}/{criterion-id}.{ext}`:

```
state/evidence/sprint-2/
├── C-01.png           # screenshot Playwright
├── C-01.json          # locator state, computed styles
├── C-02.log           # npm test output
├── C-03.har           # network trace
└── C-04.txt           # curl output + status
```

Walidator: `scripts/check-evidence-completeness.sh {n}` — każde `passed: true` ma odpowiadający plik.

---

## 5. Dotykaj tylko tego, o co cię poproszono (Scope Discipline)

**Reguła:** diff zawiera wyłącznie pliki ze zgłoszonego zakresu sprintu.

### Operacyjnie

- **Generator** przed każdym commitem: `git diff --name-only HEAD` ⊆ `paths_in_scope` z kontraktu.
- **Evaluator** w fazie 6 (verify): odrzuca PR z plikami spoza scope.
- **Pivot** zwęża scope (kasuje co `what_to_discard`), NIE rozszerza.

### Wymówki Scope Discipline (z anti-rationalization.md §2.1)

- „Refaktoryzowałem przy okazji" → cofnij + osobny sprint.
- „Naprawiłem buga w sąsiednim pliku" → jeśli nie w kontrakcie, cofnij. Bug → nowy sprint.
- „Zmieniłem konfigurację linter'a" → odrzucone. Konfiguracja repo to osobna decyzja architektoniczna.

### Walidator

```bash
bash scripts/check-scope-discipline.sh 2
# czyta paths_in_scope z state/contracts/sprint-2.json
# porównuje z git diff --name-only HEAD~N..HEAD
# zwraca exit 0 jeśli diff ⊆ paths_in_scope (poza state/* — append-only allowlisted)
```

### Wyjątki (rzadkie)

| Wyjątek | Warunek | Jak udokumentować |
|---|---|---|
| `package.json` / `package-lock.json` | Sprint dodaje zależność wymienioną w `dependencies` kontraktu | OK, ale lockfile w osobnym commicie |
| Migracje DB | Sprint jawnie modyfikuje schemat | Dodaj do `paths_in_scope` PRZED implementacją |
| `state/breadcrumbs.json` | Zawsze | Append-only, walidator inny |

---

## 6. Mapowanie Non-negotiables na fazy SKILL.md

| Non-negotiable | Faza, w której wchodzi w grę |
|---|---|
| #1 Założenia | Faza 1 (Planner) + faza 3 (negocjacja) |
| #2 Konflikt | Każda faza (eskalacja przez `blockers.md`) |
| #3 Nudne rozwiązania | Faza 4 (pętla) + faza 6 (verify, `craft` filar) |
| #4 Twardy dowód | Faza 4 (evidence) + faza 6 (audit) |
| #5 Scope | Faza 3 (paths_in_scope) + faza 6 (audit) + faza 7 (ship) |

---

## 7. Skrypt walidujący Non-negotiables

```bash
scripts/verify-non-negotiables.sh
# Sprawdza:
#   #1: state/plan.md ma sekcję Open Questions (NIE pustą)
#   #2: brak `assumed:` w kontraktach (powinno być w assumptions: [])
#   #3: brak plików z >3 warstwami abstrakcji w git diff (heurystyka: 3+ generic parameters)
#   #4: każde criterion.passed=true ma evidence file
#   #5: git diff ⊆ paths_in_scope dla każdego sprintu
```

Exit code:
- `0` — wszystkie 5 zielone.
- `N` (1-5) — Non-negotiable #N zerwany. **Sesja pauzowana.**
