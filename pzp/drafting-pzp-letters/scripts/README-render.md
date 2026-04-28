# render_docx.py — skrypt renderowania `.md` → `.docx`

Skrypt przekształca wypełniony plik `.md` pisma proceduralnego w dokument `.docx` osadzony w szablonie EZD KG PSP `wzor_pismo_przewodnie.docx`.

## Wymagania

- Python 3.10+
- `python-docx` (obligatoryjnie)
- `PyYAML` (opcjonalnie — gdy brak, skrypt używa minimalnego parsera YAML obsługującego frontmatter skilla)

Instalacja (macOS):

```bash
pip install python-docx PyYAML
```

## Użycie

```bash
python3 /Users/mklosinski/.claude/skills/drafting-pzp-letters/scripts/render_docx.py \
  --template /Users/mklosinski/Documents/GitHub/Legitymacje_OSP/OBSIDIAN/PROJEKTY/PZP/wzor_pismo_przewodnie.docx \
  --input    /path/to/W03-wyjasnienia-tresci-oferty-<slug>.md \
  --output   /path/to/W03-wyjasnienia-tresci-oferty-<slug>.docx
```

**Parametry:**

| Parametr | Opis |
|----------|------|
| `--template` | Absolutna ścieżka do `wzor_pismo_przewodnie.docx` |
| `--input` | Absolutna ścieżka do wypełnionego pliku `.md` pisma |
| `--output` | Absolutna ścieżka docelowego `.docx` |
| `--platforma` | (opcjonalny) URL platformy zakupowej — podstawiany za `<<URL platformy>>` w treści |

## Wymagania wobec pliku `.md`

Plik `.md` musi zawierać:

1. **YAML frontmatter** z obowiązkowymi polami (patrz `templates/_frontmatter-base.md`):
   - `sygnatura_postepowania`, `postepowanie`, `zamawiajacy`
   - `wykonawca`, `adres_wykonawcy` (opcjonalnie)
   - `typ_pisma`, `kod_pisma`
   - `data_pisma` (YYYY-MM-DD lub sformatowane po polsku), `miejscowosc`
   - `signatory_stanowisko`, `signatory_tytul`, `signatory_imie_nazwisko`
2. **Sekcję `## Treść pisma`** — zawartość od tego nagłówka do `## Załączniki` staje się treścią body w DOCX.
3. **Sekcje `## Załączniki`** i **`## Otrzymują`** — używane do zastąpienia odpowiednich pól w szablonie.

**Wszystkie placeholdery `<<...>>`** w frontmatterze i treści muszą być wypełnione przed renderowaniem — skrypt przerywa z błędem, gdy znajdzie niewypełniony placeholder.

## Co robi skrypt

1. **Kopiuje** szablon DOCX do pliku wynikowego (szablon nigdy nie jest modyfikowany).
2. **Wypełnia zakładki EZD** (7 szt.) — tekst w zakresie zakładki zostaje zastąpiony wartością z frontmatter:
   - `ezdSprawaZnak` ← `sygnatura_pisma` (lub `{sygnatura_postepowania}.{kod_pisma}`)
   - `ezdDataPodpisu` ← `data_pisma` (format polski: „22 kwietnia 2026")
   - `ezdPracownikNazwa` ← `{signatory_tytul} {signatory_imie_nazwisko}`
   - `ezdPracownikAtrybut1` ← `signatory_stanowisko`
   - `ezdPracownikAtrybut2` ← `signatory_tytul`
   - `ezdPracownikAtrybut3` ← `signatory_imie_nazwisko`
   - `ezdAutorWydzialOpis` — pozostawiony bez zmian (stałe „Biuro Informatyki i Łączności" z szablonu).
3. **Zamienia placeholdery `$`** w całym dokumencie (body, nagłówki, stopki):
   - `$sygnatura pisma`, `$DataPodpisu`, `$stanowisko`, `$tytuł`, `$imię i nazwisko`.
4. **Adresat**: akapit zawierający `[adresat]/[jednostka organizacyjna PSP z listy adresatów]` zostaje zastąpiony pełną nazwą wykonawcy + adresem.
5. **Body**: placeholdery „Wstęp do pisma…" i „Rozwinięcie i zasadnicza treść pisma…" zostają usunięte, a na ich miejsce wstawione akapity parsowane z sekcji `## Treść pisma` w MD. Nagłówki `###`/`####` są oznaczane jako pogrubione; cytaty (Obsidian callouts) — kursywą.
6. **Załączniki**: placeholder „Opis załącznika..." zostaje zastąpiony zawartością `## Załączniki` z MD.
7. **Otrzymują**: placeholder „Adresat (tytuł, imię, nazwisko, ...)" zostaje zastąpiony zawartością `## Otrzymują` z MD.
8. **Ostrzeżenie o signatory** — jeśli `signatory_zrodlo: memory`, skrypt wypisuje ostrzeżenie do stderr po zakończeniu.

## Rzeczy, których skrypt NIE robi

- Nie modyfikuje szablonu źródłowego.
- Nie walidacji poprawności prawnej treści — to zadanie skilla `drafting-pzp-letters`, nie skryptu.
- Nie generuje samej treści merytorycznej — tylko ją wstawia do DOCX.
- Nie modyfikuje obrazu logo w nagłówku szablonu.
- Nie zmienia czcionek zdefiniowanych w szablonie (Lato + ODTTF embedded).

## Rozwiązywanie problemów

| Błąd | Przyczyna | Rozwiązanie |
|------|-----------|-------------|
| `Missing YAML frontmatter` | Plik MD nie zaczyna się od `---` | Dodaj frontmatter zgodnie z `_frontmatter-base.md` |
| `Missing required section heading: ## Treść pisma` | Brak sekcji body | Dodaj sekcję `## Treść pisma` |
| `Missing mandatory frontmatter keys` | Brak obowiązkowego pola | Uzupełnij frontmatter |
| `Frontmatter field 'X' still contains placeholder` | Niewypełniony `<<...>>` | Wypełnij wszystkie placeholdery przed renderowaniem |
| `ImportError: python-docx is required` | Brak biblioteki | `pip install python-docx` |

## Test smoke

Na maszynie deweloperskiej można przetestować skrypt na pustym MD:

```bash
cat <<'EOF' > /tmp/test-pismo.md
---
sygnatura_postepowania: BL-V.2371.3.2026
postepowanie: "Test B10"
zamawiajacy: Komenda Główna Państwowej Straży Pożarnej
wykonawca: TEST Sp. z o.o.
adres_wykonawcy: "ul. Testowa 1, 00-000 Warszawa"
typ_pisma: wezwanie-wyjasnienia-tresci-oferty
kod_pisma: W03
data_pisma: 2026-04-22
miejscowosc: Warszawa
signatory_stanowisko: "Dyrektor BIŁ KG PSP"
signatory_tytul: "mł. bryg. mgr inż."
signatory_imie_nazwisko: "Michał Kłosiński"
signatory_zrodlo: memory
---

# Test

## Treść pisma

**Dotyczy:** postępowania testowego.

### Wstęp

To jest test.

### Żądanie

1. Wyjaśnienie testowe.

## Załączniki

nie dotyczy

## Otrzymują

1. TEST Sp. z o.o., ul. Testowa 1, 00-000 Warszawa
2. a/a
EOF

python3 /Users/mklosinski/.claude/skills/drafting-pzp-letters/scripts/render_docx.py \
  --template /Users/mklosinski/Documents/GitHub/Legitymacje_OSP/OBSIDIAN/PROJEKTY/PZP/wzor_pismo_przewodnie.docx \
  --input /tmp/test-pismo.md \
  --output /tmp/test-pismo.docx

open /tmp/test-pismo.docx
```
