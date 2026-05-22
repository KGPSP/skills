# analyzing-pzp-offers

> Weryfikacja oferty wykonawcy w postępowaniu o udzielenie zamówienia publicznego (PZP) — oferta vs SWZ/OPZ + pisma z odpowiedziami/modyfikacjami. **Każdy wniosek ma cytat z lokalizacją (plik:strona). Bez domniemań.**

[![version](https://img.shields.io/badge/version-v1.1.0-blue)]() [![size](https://img.shields.io/badge/SKILL.md-499%2F500_lines-green)]() [![domena](https://img.shields.io/badge/domena-PZP-orange)]()

---

## Co to jest

Skill dla Claude Code prowadzący **systematyczną, audytowalną weryfikację oferty** w reżimie ustawy Prawo zamówień publicznych. Produkuje serię dokumentów roboczych w Obsidian Flavored Markdown — od indeksu dokumentów, przez tabelę kontrolną i analizę sekcji A–G, po klasyfikację ryzyk odrzucenia/wezwania (F1–F6) i analizę porównawczą wielu wykonawców.

Centralna zasada (**Iron Law**): *każde stwierdzenie o wymaganiu lub niezgodności musi cytować konkretne miejsce konkretnego dokumentu* — `[DOC: plik] [Rozdz./pkt] [str.]`. Brak cytatu = bezwartościowa analiza.

## Kiedy używać

✅ **TAK** — gdy:
- Masz folder z dokumentacją postępowania (ogłoszenie, SWZ, OPZ, pisma z modyfikacjami) **i** folder z ofertą wykonawcy.
- Chcesz formalnej weryfikacji kompletności i zgodności oferty przed decyzją (odrzucenie / wezwanie / wybór).
- Potrzebujesz raportu z cytatami, tabelą kontrolną i oceną ryzyka odrzucenia.
- Porównujesz oferty wielu wykonawców.

❌ **NIE** — gdy:
- Postępowanie zagraniczne nieobjęte polską ustawą PZP.
- Wczesna faza planowania (przed publikacją SWZ) — brak dokumentacji do weryfikacji.
- Sam przegląd techniczny produktu bez kontekstu postępowania.
- Redagowanie pism proceduralnych → `drafting-pzp-letters`. Weryfikacja projektu umowy → `weryfikacja-umow-pzp`.

Pełna lista negatywnych triggerów w [SKILL.md `do-not-trigger-for`](SKILL.md).

## Jak uruchomić

W prompcie do Claude Code wskaż foldery i napisz jeden z triggerów:

```
sprawdź ofertę — ogłoszenie w <ścieżka>, oferta w <ścieżka>
```

Triggery: `sprawdź ofertę`, `zweryfikuj zgodność z SWZ`, `przeanalizuj ofertę wykonawcy`, `porównaj oferty`, `oceń kompletność oferty`.

## Workflow — 6 faz

| Faza | Cel | Exit |
|------|-----|------|
| 0 | Walidacja wejścia (ZIP/XAdES, struktura) | foldery wypisane, `<output_dir>` istnieje, `TodoWrite` |
| 1 | **Indeksacja plików** (nigdy nie pomijać) | `index-ogloszenie.md` + `index-<wykonawca>.md`, każdy plik ≥2–3 zdania |
| 2 | Ekstrakcja wymagań (wraz z ofertą / na wezwanie / fakultatywne) | katalog wymagań z źródłem i brzmieniem po modyfikacjach |
| 3 | Analiza oferty (sekcje A–G) | każde wymaganie rozstrzygnięte z cytatem |
| 4 | Generowanie raportu + serii dokumentów | komplet plików wg DoD |
| 5 | Analiza porównawcza (gdy ≥2 wykonawców) | `07-analiza-porownawcza.md` z rankingiem |

Phase 2 ma **precondition check** — bez ukończonych indeksów analiza jest nieważna (brak audit trail).

## Output — seria dokumentów (per wykonawca)

`00-podsumowanie-wykonawcze`, `01-raport-glowny`, `02-tabela-kontrolna`, `03-braki-i-niezgodnosci`, `04-analiza-szczegolowa`, `05-ocena-ryzyka`, `06-cytaty-i-zrodla` + indeksy; `07-analiza-porownawcza` gdy ≥2 wykonawców.

> Dla K wykonawców: **1 indeks ogłoszenia + K × (indeks oferty + 7 dokumentów) + (1 porównawczy gdy K≥2)**. Np. 2 wykonawców → 18 plików.

**Klasyfikacja ryzyk F1–F6**: brak nieistotny / wada uzupełnialna (art. 107/128) / wezwanie do wyjaśnień (art. 223/128) / niezgodność z WZ (art. 226 ust. 1 pkt 5) / odrzucenie (art. 226) / wykluczenie (art. 108/109 + self-cleaning art. 110).

## Kluczowe pryncypia

- **Iron Law** — każdy wniosek cytuje miejsce w dokumencie; zero „wydaje się"/„prawdopodobnie".
- **Indeksacja pierwsza** — bez niej brak audit trail przy kontroli/sporze/KIO.
- **Modyfikacje SWZ nadrzędne** — pracuj zawsze na aktualnym brzmieniu po pismach.
- **„Na wezwanie" ≠ brak** — dokumenty składane po wezwaniu (art. 126) traktowane osobno.
- **Anti-Rationalization** — tabela 9 wymówek z twardymi blokadami („Odrzucono.").

## Struktura plików

```
analyzing-pzp-offers/
├── README.md                     ← ten plik
├── SKILL.md                      ← główny prompt (499/500 linii)
├── CHANGELOG.md
├── references/
│   └── verification-prompt.md    ← heavy reference: sekcje A–G, format I–V (Phase 3)
└── templates/                    ← szablony 00–07 + index-ogloszenie + index-oferta
```

## Wymagania

- **Claude Code** (CLI lub IDE plugin).
- Dostęp do folderów postępowania i oferty (lokalnie).
- Narzędzie konwersji DOCX/PDF do tekstu (Read tool / `pdftotext`).

## Wersjonowanie

- **v1.0.0** — pierwsze wydanie (weryfikacja oferty, F1–F6, cytaty źródeł, indeks).
- **v1.1.0** — domknięcie zgodności z `DOC/`: frontmatter kanoniczny (trigger, do-not-trigger, allowed-tools, sources, size-limit), exit criteria per faza, tabela Anti-Rationalization, Definition of Done, reguły ładowania L3, `verification-prompt.md` → `references/`.

Pełna historia: `git log pzp/analyzing-pzp-offers/` oraz [CHANGELOG.md](CHANGELOG.md).

## Filozofia

> „Analiza jest ważna tylko wtedy, gdy każdy wniosek da się prześledzić do konkretnego fragmentu konkretnego dokumentu. Bez cytatu — to nie analiza, to domniemanie."

Skill jest uprzężą dyscypliny dowodowej dla zamawiającego publicznego — chroni przed odwołaniem do KIO opartym na nieudokumentowanej ocenie oferty.
