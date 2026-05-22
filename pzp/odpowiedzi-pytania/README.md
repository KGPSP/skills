# odpowiedzi-pytania

> Odpowiedzi Zamawiającego na pytania wykonawców (wyjaśnienia/modyfikacje SWZ/OPZ/umowy) w reżimie ustawy Pzp. **Model 3 hipotez + STOP-gate eskalacji.** Output: 7 plików roboczych do publikacji i akceptacji kierownika.

[![version](https://img.shields.io/badge/version-v1.1.0-blue)]() [![size](https://img.shields.io/badge/SKILL.md-483%2F500_lines-green)]() [![domena](https://img.shields.io/badge/domena-PZP-orange)]()

---

## Co to jest

Skill dla Claude Code przygotowujący **projekt odpowiedzi Zamawiającego** na pytania wykonawców (art. 135 ≥ progi / art. 284 < progi). Każde pytanie przechodzi analizę w **modelu trzech hipotez** (odpowiedź negatywna / pozytywna / kompromisowa) z oceną skutków prawnych, konkurencyjnych i terminowych, zakończoną jednoznaczną rekomendacją.

Centralna zasada: **każda odpowiedź ma jednorodną podstawę prawną i zachowuje zasadę równego traktowania wykonawców (art. 16).** Skill nie tworzy odpowiedzi eliminujących równoważność, uprzywilejowujących wykonawcę ani zmieniających charakter zamówienia bez kontroli skutków na ogłoszenie i termin.

## Kiedy używać

✅ **TAK** — gdy:
- Masz folder postępowania (SWZ + jeden lub więcej plików z pytaniami wykonawców) i chcesz kompletu odpowiedzi.
- Prosisz o wyjaśnienia treści SWZ do publikacji na platformie zakupowej.
- Chcesz ujednolicić odpowiedzi między turami pytań.

❌ **NIE** — gdy:
- Brak SWZ → najpierw przygotuj SWZ.
- Pytanie nie od wykonawcy w trybie art. 135/284 (zapytanie obywatelskie, kontrola UZP, udostępnienie protokołu).
- Postępowania zagraniczne poza polskim Pzp.
- Weryfikacja oferty → `analyzing-pzp-offers`. Pisma do wykonawcy → `drafting-pzp-letters`.

Pełna lista w [SKILL.md `do-not-trigger-for`](SKILL.md).

## Jak uruchomić

```
przygotuj odpowiedzi na pytania — folder postępowania <ścieżka>
```

Triggery: `odpowiedzi na pytania`, `wyjaśnienia treści SWZ`, `pytania wykonawców`, `modyfikacja SWZ`, `zmiana OPZ na podstawie pytań`, `art. 135 Pzp`, `art. 284 Pzp`.

## Workflow — 8 faz (z bramką STOP)

| Faza | Cel | Exit |
|------|-----|------|
| 0 | Walidacja wejścia | SWZ + pytania potwierdzone, metryka, `TodoWrite` |
| 1 | Indeksacja dokumentów | `00_indeks_dokumentow.md` |
| 2 | Identyfikacja pytań (rozbicie złożonych) | `01_rejestr_pytan.md` z obszarem i statusem |
| 3 | Analiza 3 hipotez | `02_analiza_hipotez.md` per (sub-)pytanie |
| 4 | Rekomendacja | stanowisko + status eskalacji |
| **4.5** | **STOP-gate eskalacji** | decyzje usera per pytanie **albo** „[w opracowaniu]" |
| 5 | Projekt odpowiedzi | `03_odpowiedzi_dla_wykonawcow.md` (formuła Zamawiającego, cytat pytania w całości) |
| 6 | Zakres zmian dokumentacji | `04_zmiany_dokumentacji.md` (brzmienie stare/nowe + wpływ na termin/ogłoszenie) |
| 7 | Kontrola jakości (Definition of Done) | `05_raport_ryzyk.md` + `06_wersja_do_akceptacji.md` |

**Phase 4.5 Iron Law:** skill nie wypełnia brakującej decyzji własną rekomendacją — pytanie bez decyzji zostaje „[w opracowaniu — wymaga decyzji Zamawiającego]".

## Output — 7 plików w `odpowiedzi_<RRRR-MM-DD>/`

`00_indeks_dokumentow`, `01_rejestr_pytan`, `02_analiza_hipotez`, `03_odpowiedzi_dla_wykonawcow` (do publikacji), `04_zmiany_dokumentacji`, `05_raport_ryzyk`, `06_wersja_do_akceptacji` (dla kierownika).

## Kluczowe pryncypia

- **Jednorodna podstawa prawna + jedno rozstrzygnięcie per wniosek** (pytania złożone rozbijane na sub-pytania).
- **Równe traktowanie (art. 16)** — odpowiedź pozytywna obowiązuje wszystkich; zero personalizacji.
- **Pisemność (art. 20)** — skill produkuje projekt do publikacji, nigdy nie wysyła sam.
- **Reguły terminowe** — zmiana SWZ istotna lub spóźnienie z wyjaśnieniami → obligatoryjne przedłużenie terminu (art. 135 ust. 3/137 ust. 6 / 284 ust. 3/286 ust. 3).
- **Granica zmian (art. 137 ust. 7)** — istotna zmiana charakteru → unieważnienie (art. 256), nie zmiana SWZ.
- **Anti-Rationalization** — 9 wymówek z blokadami.

## Struktura plików

```
odpowiedzi-pytania/
├── README.md                       ← ten plik
├── SKILL.md                        ← główny prompt (483/500 linii)
├── CHANGELOG.md
├── references/
│   ├── prawo-index.md              ← mapa dokumentów źródłowych (przed Phase 1)
│   ├── pzp-articles-map.md         ← pełna mapa artykułów Pzp (Phase 3)
│   ├── style-guide.md              ← formuły + zwroty zakazane (przed Phase 5)
│   └── workflow-3-hipotez.md       ← metodyka 3 hipotez (Phase 3)
└── templates/                      ← szablony 00–06
```

## Wymagania

- **Claude Code** (CLI lub IDE plugin).
- Folder postępowania z SWZ i plikami pytań (RTF/DOCX/PDF/MD).

## Wersjonowanie

- **v1.0.0** — pierwsze wydanie (3 hipotezy, STOP-gate, 7 plików, reguły terminowe art. 135/284).
- **v1.1.0** — domknięcie zgodności z `DOC/`: frontmatter kanoniczny, exit criteria, tabela Anti-Rationalization, Definition of Done, reguły ładowania L3, frontmatter referencji; **fixy**: naprawiony YAML `description`, sparametryzowane ścieżki w referencjach, korekta `do-not-trigger-for`.

Pełna historia: `git log pzp/odpowiedzi-pytania/` oraz [CHANGELOG.md](CHANGELOG.md).

## Filozofia

> „Odpowiedź na pytanie wykonawcy jest czynnością proceduralną, nie konsultacją. Najpierw analiza skutków (3 hipotezy), potem jednoznaczne rozstrzygnięcie. Decyzje o istotnym wpływie wraca do Zamawiającego — skill nie zgaduje za człowieka."

Skill łączy dyscyplinę analityczną (model 3 hipotez) z twardą bramką eskalacji — tak, by odpowiedzi były spójne, równe dla wszystkich i obronne przed KIO.
