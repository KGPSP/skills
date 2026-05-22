# drafting-pzp-letters

> Projekty pism proceduralnych do wykonawcy w postępowaniu PZP — na podstawie analizy oferty z `analyzing-pzp-offers`. **Jedno pismo = jedna podstawa prawna.** Output: `.md` (do review) + `.docx` osadzony w szablonie EZD KG PSP.

[![version](https://img.shields.io/badge/version-v1.1.0-blue)]() [![size](https://img.shields.io/badge/SKILL.md-398%2F500_lines-green)]() [![domena](https://img.shields.io/badge/domena-PZP-orange)]()

---

## Co to jest

Skill dla Claude Code, który z wykrytych w analizie oferty znalezisk (kategorie F1–F6) opracowuje **serię pism proceduralnych** kierowanych do wykonawcy: wezwania do uzupełnienia/wyjaśnień, informacje o odrzuceniu/wykluczeniu, zawiadomienia o poprawie omyłki, zawiadomienia o wyborze/unieważnieniu.

Centralna zasada: **każde pismo ma jedną jednorodną podstawę prawną.** Nigdy nie miesza się trybu wezwania do wyjaśnień (art. 223 ust. 1) z trybem wezwania do uzupełnienia (art. 128 ust. 1) — to różne instytucje z różnymi terminami i skutkami.

## Kiedy używać

✅ **TAK** — gdy:
- Masz folder z raportem `analyzing-pzp-offers` (co najmniej `03-braki-i-niezgodnosci-*.md`) i chcesz pism do publikacji.
- Prosisz o konkretne pismo („wezwanie do uzupełnienia JEDZ", „informacja o odrzuceniu na podstawie art. 226 ust. 1 pkt 5").
- Potrzebujesz projektu zawiadomienia o wyborze / unieważnieniu.

❌ **NIE** — gdy:
- Brak analizy oferty → najpierw uruchom `analyzing-pzp-offers`.
- Materiał nie daje podstaw → zamiast pisma „pro forma" skill wypisze „brak podstaw do wezwania/odrzucenia".
- Postępowania zagraniczne; korespondencja nienormatywna.
- Weryfikacja projektu umowy → `weryfikacja-umow-pzp`.

Pełna lista w [SKILL.md `do-not-trigger-for`](SKILL.md).

## Jak uruchomić

```
przygotuj wezwania — raport analizy w <ścieżka>
```

Triggery: `przygotuj wezwanie`, `napisz pismo do wykonawcy`, `informacja o odrzuceniu`, `wezwanie do uzupełnienia`, `odrzuć ofertę`, `wykluczenie wykonawcy`, `poprawa omyłki`.

## Workflow — 6 faz

| Faza | Cel | Exit |
|------|-----|------|
| 0 | Walidacja wejścia | `03-braki-*.md` potwierdzony, metryka, `<output_dir>`, `<template_docx>`, `TodoWrite` |
| 1 | Ekstrakcja znalezisk z raportu | lista znalezisk z 6 polami (kod, F, cytaty, podstawa, działanie) |
| 2 | Kwalifikacja prawna + **grupowanie** | każde znalezisko → typ pisma + template + podstawa; reguły grupowania |
| 3 | Projekt treści `.md` | pismo z pełną strukturą, 0 placeholderów, jedna podstawa prawna |
| 4 | Render `.docx` na szablonie EZD | `.docx` per pismo, szablon bazowy nietknięty |
| 5 | Metryka pism | zestawienie + sekwencja wysyłki + adnotacja o signatory |

## Output — kody pism

- **W01–W11** — Wezwania (uzupełnienie podmiotowe/przedmiotowe, wyjaśnienia treści/RNC/tajemnica, przedłużenie TZO/wadium, wymiana podmiotu, certyfikat).
- **Z01–Z05** — Zawiadomienia (poprawa omyłki pisarskiej/rachunkowej/innej, wybór, unieważnienie).
- **O01–O02** — Informacja o odrzuceniu / wykluczeniu.

Każde pismo: `.md` (review) + `.docx` (EZD) + wpis w `00-metryka-pism-<slug>.md`.

## Kluczowe pryncypia

- **Jedno pismo = jedna podstawa prawna** — różne tryby → różne pisma.
- **F4 → najpierw W03 (wyjaśnienia), dopiero potem O01 (odrzucenie)** — nigdy odwrotnie.
- **F5w → obowiązkowa weryfikacja self-cleaning (art. 110)** przed O02.
- **Zero pism pro forma** — brak podstaw = jawne „brak podstaw" z uzasadnieniem.
- **Termin ustawowy** — min. 5/10/3 dni wg podstawy, nigdy „niezwłocznie".
- **Anti-Rationalization** — 10 wymówek z blokadami (m.in. blokada „ekonomiki procesowej").

## Struktura plików

```
drafting-pzp-letters/
├── README.md                          ← ten plik
├── SKILL.md                           ← główny prompt (398/500 linii)
├── CHANGELOG.md
├── references/
│   ├── legal-basis-catalog.md         ← podstawy prawne per typ pisma (Phase 2–3)
│   └── letter-types.md                ← tabela decyzyjna F→typ+template (Phase 2)
├── scripts/
│   ├── render_docx.py                 ← render .md → .docx na szablonie EZD
│   └── README-render.md
└── templates/                         ← 18 pism (W01–W11, Z01–Z05, O01–O02) + _frontmatter-base
```

## Wymagania

- **Claude Code** (CLI lub IDE plugin).
- **Python 3** + `python-docx` — do renderu `.docx` (`scripts/render_docx.py`).
- Szablon EZD KG PSP `wzor_pismo_przewodnie.docx` (ścieżka podawana jako `<template_docx>`).
- Raport z `analyzing-pzp-offers` jako wejście.

## Wersjonowanie

- **v1.0.0** — pierwsze wydanie (pisma proceduralne, .md + .docx EZD, podstawy prawne, cytaty).
- **v1.1.0** — domknięcie zgodności z `DOC/`: frontmatter kanoniczny, exit criteria, tabela Anti-Rationalization, Definition of Done, reguły ładowania L3; **fixy**: sparametryzowana ścieżka szablonu (`<template_docx>`), naprawiony YAML `description`, exec-bit skryptu, referencje → `references/`.

Pełna historia: `git log pzp/drafting-pzp-letters/` oraz [CHANGELOG.md](CHANGELOG.md).

## Filozofia

> „Pismo proceduralne jest samodzielną czynnością w postępowaniu. Mieszanie podstaw prawnych, pisma pro forma i odrzucanie bez umożliwienia wyjaśnień — to podstawy odwołań do KIO. Skill nie ma prawa ich wprowadzać."

Skill przenosi rygor instytucji prawnych Pzp na automatyzację — tak, by każde pismo było obronne przed Krajową Izbą Odwoławczą.
