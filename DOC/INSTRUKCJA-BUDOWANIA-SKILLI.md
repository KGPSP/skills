---
title: "Instrukcja budowania skilli w repozytorium KG PSP Skills"
type: guide
status: kanoniczny
version: v1
audience: autorzy i agenci tworzący nowe skille w tym repo
tags: [agent-skills, how-to, skill-authoring, progressive-disclosure, kg-psp]
updated: 2026-05-22
---

# Instrukcja budowania skilli w tym repo

> **Typ:** guide (procedura krok-po-kroku) · **Status:** kanoniczny · **Aktualizacja:** 2026-05-22
> **Rola w korpusie `DOC/`:** operacyjny przewodnik autorski — cytowany jako `source:` (§1, §9, §10) przez skille. Teoria → [`material_skill.md`](material_skill.md), [`since_skill.md`](since_skill.md).

## Streszczenie

Praktyczny przewodnik „co zrobić krok po kroku", aby zbudować skill zgodny z pryncypiami repo: struktura katalogu, szablon `SKILL.md`, wdrożenie pięciu filarów, token budget / Progressive Disclosure, Negative Triggers, kalibracja swobody, checklista gotowości oraz wzorzec dojrzałego skilla. Uzupełnia kanoniczną teorię o gotowe szablony i anty-wzorce.

**Słowa kluczowe:** struktura katalogu skilla · szablon SKILL.md · pięć filarów · token budget · Negative Triggers · checklista gotowości · `source:` traceability.

## Spis treści

0. Zanim cokolwiek napiszesz — przeczytaj
1. Struktura katalogu skilla
2. Szablon `SKILL.md` (kopiuj-wklej)
3. Pięć filarów — jak je wdrożyć w skillu
4. Zasady stylu
5. Token budget i Progressive Disclosure
6. Calibration — kalibracja swobody
7. Negative Triggers — co skill NIE robi
8. Testowanie skilla (calibration loop)
9. Checklist gotowości skilla
10. Jak wygląda gotowy, dojrzały skill
11. Anty-wzorce (czego nie robić)
- TL;DR — minimalna ścieżka

---

> Praktyczny przewodnik dla osoby/agenta, która tworzy nowy skill w repozytorium `KGPSP/skills` (root: `<repo-root>`). Teoria stoi w `material_skill.md` i `since_skill.md`. Tutaj jest **co zrobić krok po kroku** + gotowe szablony.

---

## 0. Zanim cokolwiek napiszesz — przeczytaj

| Plik | Kiedy zajrzeć |
|---|---|
| [material_skill.md](material_skill.md) | Pryncypia procesowe: Process over Prose, Anti-Rationalization, DoD, Scope Discipline, Hyrum, Chesterton, Beyoncé, DAMP, 5 Non-negotiables. **Zawsze.** |
| [since_skill.md](since_skill.md) | Pryncypia projektowe skilla: token budget, kebab-case, imperatyw, scripts/, Negative Triggers, Anti-Laziness, Plan-Validate-Execute, Five-Axis Review, Thin Vertical Slices, Prove-It. **Zawsze.** |
| [goal_mode.md](goal_mode.md) | Gdy skill ma mieć tryb `/goal` (autonomiczna pętla AC). |
| [agent-teams-generator-ewaluator.md](agent-teams-generator-ewaluator.md) | Gdy skill orkiestruje wielu sub-agentów (wzorzec Generator–Ewaluator). |
| [agenci-ai-2026-przeglad-ekosystemu.md](agenci-ai-2026-przeglad-ekosystemu.md) | Tło teoretyczne (harness, context rot, Ralph Loop) — opcjonalnie. |

**Reference implementation:** [`dev/audited-feature-workflow/SKILL.md`](../dev/audited-feature-workflow/SKILL.md) + cały folder `references/`. Skopiuj go i przerób — szybciej niż pisanie od zera.

---

## 1. Struktura katalogu skilla

```
my-skill/
├── SKILL.md              ← jeden plik wejściowy, max 500 linii / ~5000 znaków
├── references/           ← rozszerzenia ładowane progresywnie
│   ├── protocol-X.md
│   └── protocol-Y.md
├── scripts/              ← deterministyczne narzędzia (Code Execution Tool)
└── assets/               ← rubryki, szablony, przykłady few-shot
```

**Lokalizacja w repo (wybierz domenę):**
- `dev/<nazwa-skilla>/` — workflow inżynierski (kod, review, deploy)
- `pzp/<nazwa-skilla>/` — zamówienia publiczne
- `legal/<nazwa-skilla>/` — opinie prawne
- nowa domena → nowy folder na poziomie root

---

## 2. Szablon `SKILL.md` (kopiuj-wklej)

```markdown
---
name: <nazwa-w-kebab-case>
description: <1–2 zdania CO robi i KIEDY użyć. Konkretnie, nie marketingowo.>
trigger:
  - "<fraza wyzwalająca 1>"
  - "<fraza wyzwalająca 2>"
do-not-trigger-for:
  - "<negative trigger — co NIE jest twoją robotą>"
  - "<jeszcze jeden>"
model: claude-opus-4-7
allowed-tools: ['Bash', 'Read', 'Edit', 'Write', 'Grep', 'Glob', 'TodoWrite']
sources:
  - DOC/material_skill.md
  - DOC/since_skill.md
version: v1
size-limit: 500-lines-hard
---

# <nazwa-skilla> — <jednolinijkowe co i po co>

> [!quote] Anti-Laziness preamble (since_skill.md §6)
> Najwyższa waga jakości. **Nie optymalizuj pod szybkość implementacji.** Każda bramka i każdy artefakt dowodowy jest nienegocjowalny.

> [!important] 5 Non-negotiables (material_skill.md §8)
> 1. Uwidaczniaj założenia przed budowaniem.
> 2. Zatrzymaj się przy konflikcie wymagań.
> 3. Wybieraj rozwiązania nudne i oczywiste.
> 4. Dostarczaj twardy dowód, nie deklarację.
> 5. Dotykaj tylko tego, o co cię poproszono.

---

## Procedura (Process over Prose)

### Faza 1 — <Define>
1. <krok>
2. <krok>
**Exit criterion:** <mierzalny artefakt>

### Faza 2 — <Plan>
…

### Faza N — <Verify / Ship>
…

---

## Anti-Rationalization

| Wymówka | Riposta (blokada) |
|---|---|
| „Zmiana za mała na spec" | 5 linii minimum, 0 to dług. |
| „Testy później" | „Później" nie istnieje. Failing test przed implementacją. |
| „Kod działa lokalnie" | Wklej log/trace/screenshot. Bez tego nie istnieje. |
| „Refaktoryzowałem przy okazji" | Scope Discipline. Cofnij, zgłoś osobny task. |
| <wymówka specyficzna dla domeny> | <riposta> |

---

## Definition of Done

- [ ] Clean build (warnings as errors)
- [ ] Beyoncé Rule — każda zmiana ma test
- [ ] Runtime evidence (log / screenshot / wynik endpointu)
- [ ] PR Sizing ≤ 100 linii (300 z uzasadnieniem, 1000 = przerwij i podziel)
- [ ] Scope Discipline — diff tylko w plikach z zakresu
- [ ] <domenowe DoD>

---

## Sources

- [DOC/material_skill.md](../../DOC/material_skill.md) — pryncypia procesowe.
- [DOC/since_skill.md](../../DOC/since_skill.md) — pryncypia projektowe skilla.
- <dodatkowe>
```

---

## 3. Pięć filarów — jak je wdrożyć w skillu

### Filar 1: Process over Prose
- Wyrzuć z SKILL.md eseje "bądź ekspertem", "dbaj o jakość".
- Każda sekcja ma **numerowane kroki** i **exit criterion** (mierzalny artefakt).
- Test: czy agent mógłby pominąć krok i mieć dobre uzasadnienie? Jeśli tak — krok jest za miękki.

### Filar 2: Anti-Rationalization
- Tabela 4–8 wymówek typowych dla tej domeny.
- **Riposta = blokada, nie sugestia.** Format: "Odrzucono. <konsekwencja>. <co zrobić zamiast>."
- Przykład domenowy w `pzp/odpowiedzi-pytania/` — wymówki typu "wystarczy odpowiedzieć ogólnie" mają twarde riposty.

### Filar 3: Verification is Non-negotiable
- Każda faza kończy się **artefaktem dowodowym**, nie deklaracją.
- Akceptowalne: log z konsoli, build output, runtime trace, screenshot, hash gita, output endpointu.
- Nie-akceptowalne: "wydaje się działać", "powinno przejść", "z mojej analizy".

### Filar 4: Progressive Disclosure
- `SKILL.md` ≤ 500 linii. Twarda granica.
- Rozbudowane protokoły → `references/<temat>.md`, ładowane gdy potrzebne.
- Każdy plik referencyjny ma w nagłówku **kiedy się go ładuje** (trigger phrase).
- Przykład: `references/goal-mode-protocol.md` ładuje się tylko gdy user napisze `/goal`.

### Filar 5: Scope Discipline
- W SKILL.md wpisz wprost: "Dotykaj wyłącznie plików w zakresie zadania."
- Jeśli skill może modyfikować pliki — wymień w `allowed-tools` tylko narzędzia, których naprawdę potrzebuje.
- Domyślnie wyłącz `Write` jeśli skill ma tylko analizować.

---

## 4. Zasady stylu (since_skill.md §6)

| ❌ Unikaj | ✅ Stosuj |
|---|---|
| „Powinieneś sprawdzić X" | „Weryfikuj X" (imperatyw) |
| Ścieżki absolutne `/Users/...` | `{baseDir}/...` lub relatywne |
| `MyFolder_2`, `My Folder` | `my-folder` (kebab-case, bez spacji, bez wielkich liter) |
| Drugoosobowa proza | Listy, tabele, numerowane kroki |
| Skala 1–10 dla jakości | Twarde progi binarne ("0 błędów lintera") |

**Nazwa skilla:** kebab-case, max 64 znaki, opisowa (`api-error-diagnosis`, nie `helper`).

**Description w frontmatterze:** mówi **CO** robi i **KIEDY** użyć. Router meta-skilla decyduje na podstawie tej linijki, czy aktywować — niedoprecyzowanie kosztuje aktywacje pod złe zadania.

---

## 5. Token budget i Progressive Disclosure

| Poziom | Ile tokenów | Co tam siedzi |
|---|---|---|
| **L1: Frontmatter** | 30–50 | YAML z `name`, `description`, `trigger`. Ładuje się zawsze. |
| **L2: SKILL.md body** | ≤ 5000 | Procedura, anti-rationalization, DoD. Ładuje się gdy router wybierze skill. |
| **L3: `references/*.md`** | dowolnie | Szczegółowe protokoły. Ładuje się gdy SKILL.md jawnie wskaże + warunek. |
| **L4: `scripts/`** | bez limitu | Deterministyczne narzędzia wywoływane przez Code Execution Tool. |

Reguła aktywacji L3: w SKILL.md napisz wprost *"Jeśli <warunek>, załaduj `references/<plik>.md`"* — nie pozostawiaj decyzji modelowi.

---

## 6. Calibration — kalibracja swobody (since_skill.md §6)

Dostosuj rygor do wrażliwości operacji:

| Strefa | Charakter | Rygor |
|---|---|---|
| **Strefa wolna** | CRUD biznesowy, frontend, treści | Szerokie spektrum, agent uzasadnia wybory. |
| **Fragile Operations** | Migracje DB, infra, deploy | Agent traci kreatywność, **powtarza komendy z runbooka krok po kroku**. |
| **Destruktywne** | DROP, rm -rf, force push | **Plan-Validate-Execute** — agent generuje plan → waliduje z bazą prawdy → wykonuje. |

W SKILL.md zaznacz jawnie, w której strefie pracuje (lub w której fazie wchodzi w którą strefę).

---

## 7. Negative Triggers — co skill NIE robi

Każdy SKILL.md musi mieć `do-not-trigger-for:` w frontmatterze. Bez tego router aktywuje skill przy banalnych zadaniach ("przeczytaj plik X"), co marnuje kontekst i pogarsza precyzję.

Wzorzec:
```yaml
do-not-trigger-for:
  - "przeczytaj plik X"
  - "wytłumacz co robi ten kod"
  - "popraw literówkę"
  - jednoliniowe poprawki bez impactu
  - eksploracja repozytorium bez zamiaru zmiany
```

---

## 8. Testowanie skilla (calibration loop)

**Sekret kalibracji nie jest w sprytnym prompcie, tylko w czytaniu logów (traces).**

1. **Odpal skill na 3–5 realnych zadaniach** z domeny.
2. **Przeczytaj surowe traces linijka po linijce** — gdzie model się rozjechał z twoim osądem?
3. **Doprecyzuj prompt/rubrykę** w miejscu rozjazdu, nie ogólnie.
4. **Powtórz.**

Anti-pattern: dodawanie kolejnych ogólnych instrukcji w nadziei, że "trafią". Działają tylko punktowe poprawki na zaobserwowane porażki.

---

## 9. Checklist gotowości skilla

Zanim oddasz skill do użycia:

- [ ] `SKILL.md` ≤ 500 linii, frontmatter kompletny (name, description, trigger, do-not-trigger-for, allowed-tools, sources, version).
- [ ] Numerowana procedura z exit criterion po każdej fazie.
- [ ] Tabela anty-racjonalizacji z 4+ wymówkami specyficznymi dla domeny.
- [ ] DoD checklist (Build / Beyoncé / Runtime / PR Sizing / Scope).
- [ ] Negative triggers wymienione w `do-not-trigger-for:`.
- [ ] Nazwy w kebab-case, ścieżki relatywne lub przez `{baseDir}`, imperatyw zamiast "powinieneś".
- [ ] `references/*.md` jeśli treść nie mieści się w 500 liniach + jawne reguły ładowania.
- [ ] `scripts/` jeśli skill robi deterministyczne obliczenia (model jest słaby w rutynie).
- [ ] Calibration loop — przejechany na min. 3 realnych zadaniach z czytaniem traces.
- [ ] Sources w frontmatterze wskazują na `DOC/material_skill.md`, `DOC/since_skill.md` (i domenowe).
- [ ] Wpisany do CHANGELOG.md repo jako nowa wersja.

---

## 10. Jak wygląda gotowy, dojrzały skill

Spójrz na referencyjną implementację:

```
dev/audited-feature-workflow/
├── SKILL.md                          ← <500 linii, frontmatter pełny
└── references/
    ├── ac-protocol.md                ← ładowany w Phase 4
    ├── analysis-protocol.md
    ├── anti-rationalization.md
    ├── code-review-protocol.md
    ├── dod-evidence-protocol.md
    ├── five-axis-review.md
    ├── fragile-operations-protocol.md
    ├── goal-mode-protocol.md         ← ładowany na /goal
    ├── gotchas.md
    ├── incremental-implementation.md
    ├── non-negotiables.md
    └── testing-protocol.md
```

Każdy plik w `references/` ma w nagłówku `source:` wskazujący na konkretną sekcję `material_skill.md` lub `since_skill.md` z numerem (§1, §3, §4, §5, §6). To pozwala audytować, skąd wzięła się zasada, i ułatwia aktualizację gdy kanoniczne źródło się zmienia.

---

## 11. Anty-wzorce (czego nie robić)

- **Esej zamiast procedury** — "agent powinien starannie przeanalizować…" zamiast "1. Uruchom X. 2. Wklej output. 3. Jeśli błąd → załaduj `references/error.md`."
- **Brak DoD** — kończysz fazę bez mierzalnego artefaktu? Agent zadeklaruje "done" i pójdzie dalej z gnijącym stanem.
- **Wszystko w jednym pliku** — SKILL.md 2000 linii zatruwa kontekst, model gubi się w środku.
- **Skala 1–10 w rubryce** — model siada na "7/10", przepuszcza wszystko. Stosuj progi binarne.
- **Brak negative triggers** — skill odpala się przy "co tu robi ten plik" i marnuje aktywacje.
- **Mock zamiast realnego źródła** — agent halucynuje. Zawsze grunt w runbookach, historycznych PR-ach, traces incydentów.
- **Refaktor "przy okazji" w SKILL.md** — sam skill też podlega Scope Discipline. Jeden skill = jeden cel.

---

## TL;DR — minimalna ścieżka

1. Skopiuj `dev/audited-feature-workflow/SKILL.md` jako szablon.
2. Przerób frontmatter (name, description, trigger, do-not-trigger-for, sources).
3. Napisz procedurę: numerowane kroki + exit criterion na fazę.
4. Dodaj tabelę anty-racjonalizacji (4–8 wymówek z twojej domeny).
5. Dodaj DoD checklist.
6. Wynieś rozbudowane protokoły do `references/`.
7. Odpal na 3 realnych zadaniach, czytaj traces, popraw punktowo.
8. Wpisz do CHANGELOG.

Reszta — w canonical sources: [material_skill.md](material_skill.md), [since_skill.md](since_skill.md).
