---
title: Mapowanie ról na Agent Teams w Claude Code (i skalowanie do 7+ agentów)
load-when: "Faza 2 SKILL.md (spawn) LUB plan przewiduje ≥5 sprintów (skalowanie)"
source:
  - DOC/agent-teams-generator-ewaluator.md §2 (Role w zespole)
  - DOC/agent-teams-generator-ewaluator.md §6 (Realizacja w Claude Code z Agent Teams)
---

# Mapowanie ról i skalowanie zespołu

> **Żelazna reguła:** każdy agent generujący cokolwiek MUSI mieć dedykowanego ewaluatora. Bez tego — halucynacje + sędzia we własnej sprawie.

---

## 1. Rdzeń: 3 agenty (minimalna konfiguracja)

| Rola | Okno kontekstowe | Tools | NIE ma dostępu do |
|---|---|---|---|
| **Planner** | osobne | Read, Write (state/plan.md), Grep | edytora kodu, git push, narzędzi runtime |
| **Generator** | osobne | Read, Write, Edit, Bash (git, npm, build), Glob | Playwright/Chrome MCP, Computer Use, screenshots |
| **Evaluator** | osobne | Read (read-only na repo), Bash (curl, smoke testy), **Playwright MCP**, **Chrome DevTools MCP**, **Computer Use**, **playwright CLI** | Edit, Write (poza `state/contracts/*` i `state/evidence/*`) |

### Dlaczego separacja narzędzi

- **Generator z dostępem do Playwright** → testuje własny kod = sędzia we własnej sprawie.
- **Evaluator z dostępem do edytora** → przestaje być krytykiem, staje się współautorem.
- **Planner z dostępem do Bash** → wpada w pokusę kodowania zamiast specyfikacji.

Separacja **enforce'owana w prompcie systemowym** (lista `allowed-tools` per agent) ORAZ w skrypcie weryfikacyjnym: `scripts/verify-role-isolation.sh`.

---

## 2. Prompty systemowe — szablony

### 2.1 Planner

```
Jesteś Plannerem w zespole Agent Teams. Twoje zadanie:
- Zamień prompt użytkownika w specyfikację wysokopoziomową.
- Podziel pracę na 3-15 sprintów z mierzalnymi celami biznesowymi.
- Wymień zewnętrzne zależności (API, biblioteki, dane).
- Wymień NIEWIADOME do eskalacji (Non-negotiable #1: uwidaczniaj założenia).

ZAKAZ:
- Nie projektuj architektury technicznej.
- Nie wybieraj bibliotek.
- Nie pisz pseudokodu.
- Nie podejmuj decyzji o API contract.

Output: state/plan.md w formacie z assets/plan-template.md.
```

### 2.2 Generator

```
Jesteś Generatorem w zespole Agent Teams. Twoje zadanie:
- Czytaj kontrakt z state/contracts/sprint-{n}.json.
- Implementuj kod realizujący WSZYSTKIE kryteria binarne kontraktu.
- Po każdej zmianie: commit z czytelnym message.
- Czytaj feedback z evaluator_review w kontrakcie.

REGUŁY:
- Feedback Evaluatora opisuje CO nie działa, NIE jak naprawić. Sam szukasz rozwiązania.
- Każda funkcja w diffie ma test (Beyoncé Rule).
- Diff per commit ≤100 linii (do 300 z uzasadnieniem).
- Scope Discipline: NIE modyfikuj plików spoza sprintu.
- Append-only do state/breadcrumbs.json po każdej iteracji.

ZAKAZ:
- Nie uruchamiaj Playwright/Chrome/Computer Use.
- Nie pisz do state/evidence/.
- Nie deklaruj "done" bez evidence od Evaluatora.
```

### 2.3 Evaluator

```
Jesteś Evaluatorem w zespole Agent Teams. Twoje zadanie:
- Oceniaj kod Generatora WYŁĄCZNIE wg kontraktu w state/contracts/sprint-{n}.json.
- Uruchamiaj aplikację (Playwright/Chrome/Computer Use), nie czytaj diffów.
- Zapisuj evidence (screenshot, log, trace) w state/evidence/sprint-{n}/.
- Werdykt: JSON dopisany do kontraktu (criteria_results, summary, verdict).

REGUŁY:
- Kryteria binarne (passed: true/false). ZAKAZ skal 1-10.
- Feedback dla Generatora: opisz CO nie działa, NIE jak naprawić.
- Każde "passed: true" ma plik evidence.
- Po MAX_ITERATIONS bez progresu: pivot_recommended: true.

ZAKAZ:
- Nie modyfikuj kodu (tylko read-only).
- Nie akceptuj "wydaje się działać" — wymagaj artefaktu.
- Nie zmieniaj kontraktu retroaktywnie ("to kryterium było słabe").
```

---

## 3. Rozbudowa: do 7+ agentów

Przy projektach >5 sprintów lub złożonym stosie:

| Sub-agent | Rola | Dedykowany Evaluator |
|---|---|---|
| **Frontend Builder** | UI layer, komponenty, stylowanie | Frontend QA (Playwright + visual regression) |
| **Backend Builder** | API, logika serwerowa, baza danych | Backend QA (curl + integration tests + DB inspector) |
| **Integrator** | Spaja FE+BE+DB, deployment config | E2E QA (Playwright full flow) |
| **Synthetic Data Generator** | Buduje fixtures, seed data, mocki | Data QA (schema validation, edge case coverage) |

**Pełna konfiguracja:** 1 Planner + 4 Builderzy + 4 Evaluatorzy = 9 agentów. W cytowanym projekcie Anthropic — 7 (Planner + 3 Builderzy + 3 Evaluatorzy + Integrator).

### 3.1 Potok kaskadowy

```
Planner → state/plan.md
   │
   ├──→ Synthetic Data Gen ──→ Data QA ──→ state/fixtures/
   │
   ├──→ Backend Builder ──→ Backend QA ──→ state/evidence/be/
   │
   ├──→ Frontend Builder ──→ Frontend QA ──→ state/evidence/fe/
   │
   └──→ Integrator ──→ Final QA ──→ state/evidence/e2e/
```

Każda strzałka `→` = wymiana plików w `state/`, nie message passing w jednym oknie.

### 3.2 Kiedy NIE skalować

- Sprintów ≤3 → minimalna konfiguracja (3 agenty) wystarcza.
- Pojedynczy plik / pojedyncza funkcja → użyj `audited-feature-workflow`, nie agent-teams.
- Brak smoke testu / brak Playwright → skalowanie tylko pogłębi chaos.

---

## 4. Izolacja okien kontekstowych

Każda rola = osobne okno. Co to znaczy operacyjnie:

| Co widzi okno | Generator | Evaluator |
|---|---|---|
| Prompt systemowy roli | TAK | TAK |
| Kontrakt sprintu (state/contracts/) | TAK | TAK |
| Plan Plannera (state/plan.md) | TAK (wstrzykiwany co 3-4 iteracje) | TAK |
| Wewnętrzne rozumowanie drugiej roli | **NIE** | **NIE** |
| Pełna historia czatu drugiej roli | **NIE** | **NIE** |
| Surowy diff kodu | TAK | **NIE — Evaluator czyta tylko evidence + uruchomioną app** |
| Screenshoty / logs runtime | **NIE — Generator nie testuje** | TAK |

**Powód:** generator widzący "Evaluator myśli że ten przycisk powinien być niebieski" zacznie cieniować pod ocenę zamiast pod kontrakt. Czystość kontekstu = obiektywność oceny.

---

## 5. Komunikacja peer-to-peer (Agent Teams)

Agent Teams w Claude Code obsługuje peer-to-peer **bez** orkiestratora:

- Generator wywołuje sub-agenta `evaluator` przez Task tool z parametrem `subagent_type: "evaluator"`.
- Evaluator zwraca strukturę JSON, NIE prozę.
- Generator dopisuje wynik do kontraktu i kontynuuje pętlę.
- Raportowanie do nadrzędnego agenta (głównego okna chat) **tylko** przy:
  - Eskalacji (konflikt wymagań).
  - Zakończeniu sprintu (success).
  - Pivocie (wymaga audit trail).

**Nie raportuj każdej iteracji do głównego okna** — zatruwa to kontekst master agenta.

---

## 6. Skrypt weryfikacji izolacji

```bash
scripts/verify-role-isolation.sh
```

Sprawdza:

- Czy `prompts/generator.md` zawiera frazę "ZAKAZ Playwright" (lub równoważną).
- Czy `prompts/evaluator.md` zawiera frazę "ZAKAZ Edit" (tylko read-only).
- Czy w `state/breadcrumbs.json` events `iteration_verdict` mają `actor == "evaluator"`, NIE `"generator"`.
- Czy w `state/evidence/` pliki mają w metadata `produced_by: "evaluator"`.

Brak exit 0 = łamanie reguły izolacji = sesja przerywana.

---

## 7. Ograniczenia Agent Teams w Claude Code

Co rozwiązuje:
- Rozdzielenie ról i kontekstów.
- Peer-to-peer komunikacja.
- Brak konieczności pisania orkiestratora.

**Czego NIE rozwiązuje:**
- **Środowisko uruchomieniowe.** Claude Code działa lokalnie w terminalu. Wielogodzinna sesja podatna na: uśpienie maszyny, awarię terminala, błędy środowiska.
- **Dla pracy >6h non-stop** rozważ migrację architektury do Agent SDK z sandboxem chmurowym. Agent Teams = poligon doświadczalny, Agent SDK = produkcja.
