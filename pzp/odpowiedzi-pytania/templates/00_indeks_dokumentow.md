---
sygnatura_postepowania: <<sygnatura, np. BL-V.2371.3.2026>>
postepowanie: "<<krótka nazwa, np. B10: HPC/AI dla SOiA>>"
zamawiajacy: <<np. Komenda Główna Państwowej Straży Pożarnej>>
data_wyjasnien: <<RRRR-MM-DD>>
typ_dokumentu: indeks-dokumentow
status: draft
autor: claude@kg.straz.gov.pl
prog_unijny: <<tak | nie>>
termin_skladania_ofert: <<RRRR-MM-DD HH:MM | nieustalony>>
tryb: <<np. przetarg nieograniczony | tryb podstawowy art. 275 pkt 1>>
folder_postepowania: <<absolutna ścieżka do <folder_pzp>>>
tags:
  - pzp/wyjasnienia
  - pzp/sygnatura/<<sygnatura w slug>>
  - pzp/etap/wyjasnienia-swz
---

> [!info] Indeks dokumentów postępowania
> Roboczy wykaz dokumentów z folderu postępowania `<<folder_pzp>>` na potrzeby przygotowania odpowiedzi na pytania wykonawców z dnia <<RRRR-MM-DD>>. Powiązane: [[01_rejestr_pytan]], [[02_analiza_hipotez]], [[03_odpowiedzi_dla_wykonawcow]], [[04_zmiany_dokumentacji]], [[05_raport_ryzyk]], [[06_wersja_do_akceptacji]].

# Indeks dokumentów postępowania

**Sygnatura postępowania:** <<sygnatura>>
**Tryb:** <<tryb>>
**Próg unijny:** <<tak | nie>>
**Termin składania ofert:** <<RRRR-MM-DD HH:MM>>
**Folder postępowania:** `<<absolutna ścieżka>>`

## Wykaz dokumentów

| Plik | Rodzaj | Data | Znaczenie | Zawiera Q&A |
| --- | --- | --- | --- | --- |
| `<<plik 1>>` | <<SWZ \| OPZ \| PPU \| umowa \| formularz ofertowy \| ogłoszenie \| pytania \| odpowiedzi \| modyfikacja \| załącznik techniczny \| notatka \| opinia \| analiza \| robocze>> | <<RRRR-MM-DD lub b.d.>> | <<krótki opis znaczenia dla Q&A>> | <<TAK \| NIE>> |
| `<<plik 2>>` | … | … | … | … |

## Wcześniejsze tury Q&A (jeśli dotyczy)

| Plik | Data | Liczba pytań | Liczba odpowiedzi | Zmiany dokumentacji |
| --- | --- | --- | --- | --- |
| `<<np. odpowiedzi-1-2026-04-15.docx>>` | <<RRRR-MM-DD>> | <<N>> | <<N>> | <<TAK/NIE — krótki opis>> |

## Pliki z pytaniami w bieżącej turze

| Plik | Data wpływu | Wykonawca (jeśli ujawniony) | Liczba pytań | Pierwsze pytanie ID |
| --- | --- | --- | --- | --- |
| `<<np. pytania-2026-04-22.docx>>` | <<RRRR-MM-DD>> | <<nazwa lub „nieujawniony">> | <<N>> | Q01 |

## Decyzje Zamawiającego — informacje brakujące

> [!warning] Wypełnij sekcję, jeżeli któreś z poniższych nie da się ustalić z dokumentów postępowania.

- [ ] Sygnatura postępowania: <<status — ustalono / wymaga decyzji>>
- [ ] Termin składania ofert: <<status>>
- [ ] Próg unijny: <<status>>
- [ ] Tryb postępowania: <<status>>
- [ ] Lista wcześniejszych tur Q&A: <<status>>

## Powiązane dokumenty z bazy PRAWO

> Wskazania do `references/prawo-index.md` skilla `odpowiedzi-pytania`.

- Ustawa Pzp (Dz.U. 2024 poz. 1320 ze zm.) — `[[D20192019Lj]]`
- Regulamin KG PSP — `[[regulamin_kg_psp]]`
- Wzór umowy: <<dostawa | usługa>> — `[[szablon-1-umowa_<<typ>>]]`

## Status pracy

- [ ] Phase 0 — Walidacja wejścia
- [ ] Phase 1 — Indeksacja dokumentów (ten plik)
- [ ] Phase 2 — Identyfikacja pytań → `01_rejestr_pytan.md`
- [ ] Phase 3 — Analiza 3 hipotez → `02_analiza_hipotez.md`
- [ ] Phase 4 — Rekomendacje
- [ ] Phase 5 — Projekt odpowiedzi → `03_odpowiedzi_dla_wykonawcow.md`
- [ ] Phase 6 — Zmiany dokumentacji → `04_zmiany_dokumentacji.md`
- [ ] Phase 7 — Kontrola jakości + raport ryzyk + akceptacja → `05_raport_ryzyk.md`, `06_wersja_do_akceptacji.md`
