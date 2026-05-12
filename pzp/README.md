# `pzp/` — Prawo Zamówień Publicznych

Skille obsługujące cykl postępowania o udzielenie zamówienia publicznego w reżimie ustawy Pzp — od wyjaśnień SWZ przez analizę oferty po projekt umowy.

## Skille w tej kategorii

| Skill | Faza postępowania | Output |
|-------|---|---|
| [`odpowiedzi-pytania`](odpowiedzi-pytania/) | Przed otwarciem ofert | 7 plików roboczych: indeks dokumentów, rejestr pytań, analiza 3-hipotez, finalne odpowiedzi, wykaz zmian SWZ/OPZ, raport ryzyk, wersja do akceptacji kierownika |
| [`analyzing-pzp-offers`](analyzing-pzp-offers/) | Po otwarciu ofert | Raport weryfikacji oferty (oferta vs SWZ/OPZ + modyfikacje) z cytatami źródeł i indeksem dokumentów |
| [`drafting-pzp-letters`](drafting-pzp-letters/) | Procedura ocenowa | Projekty pism proceduralnych (.md + .docx EZD): wezwania do uzupełnienia/wyjaśnień, informacje o odrzuceniu/wykluczeniu, zawiadomienia, wybór/unieważnienie |
| [`weryfikacja-umow-pzp`](weryfikacja-umow-pzp/) | Przed podpisaniem umowy | Audyt projektu umowy/PPU — pary **cytat obecnego brzmienia + proponowane brzmienie** dla każdej wykrytej wady |

---

## Wspólne konwencje

- **Format outputu**: Obsidian Flavored Markdown z frontmatterem YAML (gotowe do vaulta KG PSP).
- **Cytowanie źródeł**: każde stwierdzenie z dokumentu źródłowego (SWZ, oferta, OPZ, pytanie) musi mieć precyzyjny cytat z lokalizacją (sekcja, strona, paragraf).
- **Konwencja folderów**: skille generują artefakty w folderze postępowania (`<postępowanie>/odpowiedzi_<RRRR-MM-DD>/`, `<postępowanie>/analiza-oferty-<wykonawca>/`).
- **Akceptacja kierownika**: skille generują wersję `do_akceptacji.md` osobno od `final.md` — kierownik zatwierdza przed publikacją.

## Reżim ustawy Pzp

Wszystkie skille operują na aktualnym brzmieniu **ustawy Prawo Zamówień Publicznych** (Dz. U. z 2019 r. poz. 2019 z późn. zm.) wraz z aktami wykonawczymi. Każdy skill cytuje konkretne artykuły (np. art. 135 — wyjaśnienia SWZ, art. 284 — modyfikacje, art. 226 — odrzucenie oferty).

## Wybór skilla — quick guide

- **„Przyszły pytania od wykonawców"** → `odpowiedzi-pytania`
- **„Otworzyliśmy oferty, sprawdź wykonawcę X"** → `analyzing-pzp-offers`
- **„Trzeba wezwać do uzupełnienia / odrzucić / unieważnić"** → `drafting-pzp-letters`
- **„Mamy projekt umowy do podpisania"** → `weryfikacja-umow-pzp`
