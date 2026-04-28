---
sygnatura: <<sygnatura>>
postepowanie: "<<nazwa_postepowania>>"
zamawiajacy: <<zamawiajacy>>
typ_dokumentu: indeks-ogloszenia
data_utworzenia: <<data_yyyy-mm-dd>>
platforma_zakupowa: <<url>>
termin_skladania_ofert: <<data>>
termin_realizacji: <<data>>
wartosc_szacunkowa: <<kwota>>
tryb: <<przetarg_nieograniczony | podstawowy | ...>>
tags:
  - pzp/indeks
  - pzp/ogloszenie
  - pzp/sygnatura/<<slug-sygnatury>>
---

# Indeks dokumentów postępowania — <<krótka nazwa postępowania>>

> [!info] Meta postępowania
> - **Nr sprawy:** <<sygnatura>>
> - **Zamawiający:** <<pełna nazwa + adres>>
> - **Przedmiot:** <<1–2 zdania z ogłoszenia / SWZ>>
> - **Miejsce realizacji:** <<adres + kod NUTS>>
> - **Termin realizacji:** <<data>>
> - **Termin składania ofert:** <<data, godz.>>
> - **Platforma zakupowa:** <<url>>
> - **Tryb:** <<tryb>>
> - **CPV:** <<kody>>
> - **Kryteria oceny:** <<cena X pkt, pozostałe Y pkt>>

---

## Dokumenty główne postępowania

### <<nazwa pliku z rozszerzeniem>>

<<2–4 zdania opisu: tytuł właściwy, podpisujący, nr TED / Dz.U., klasyfikacja CPV, miejsce, tryb, kryteria oceny (wagi), warunki udziału — wszystko z konkretami: daty, numery, nazwiska, liczby.>>

### <<nazwa pliku>>

<<...>>

---

## Pisma — wyjaśnienia i zmiany SWZ

> [!warning] Chronologia nadrzędna
> Kolejne pisma są **nadrzędne** wobec pierwotnego brzmienia SWZ/OPZ. Przy analizie zawsze pracuj na aktualnym brzmieniu.

### <<nazwa pisma>>.pdf

<<Data pisma, czego dotyczy, które rozdziały SWZ/punkty OPZ modyfikuje, czy zmienia termin składania ofert, charakter zmiany (liberalizujący/zaostrzający/wyjaśniający). Wskaż konkretnie: „zmienia Rozdział VII ust. 2 pkt 4 lit. a SWZ — wydłuża okres referencyjny z 3 do 5 lat".>>

---

## Załączniki do SWZ

### Zał nr <<N>> do SWZ_<<nazwa>>.<<ext>>

<<Tytuł właściwy, charakter (przedmiotowy/podmiotowy środek dowodowy, oświadczenie, formularz, wzór umowy), kategoria składania (wraz z ofertą / na wezwanie / fakultatywny), kluczowe treści.>>

### <<...>>

---

## Chronologia postępowania

| Data | Dokument / Zdarzenie | Uwagi |
|------|----------------------|-------|
| <<dd.mm.rrrr>> | Publikacja ogłoszenia o zamówieniu | TED <<nr>> |
| <<dd.mm.rrrr>> | <<pismo>> | <<co zmienia>> |
| <<dd.mm.rrrr>> | Termin składania ofert | — |
| <<dd.mm.rrrr>> | Termin realizacji zamówienia | — |

## Katalog dokumentów „wraz z ofertą" vs „na wezwanie"

| Dokument | Podstawa SWZ | Wraz z ofertą? | Na wezwanie? | Fakultatywny? |
|----------|--------------|----------------|--------------|---------------|
| Formularz oferty | `[DOC] [Rozdz. N]` | ✅ | — | — |
| JEDZ | `[DOC] [Rozdz. N]` | ✅ | — | — |
| OPZ (jeśli przedm. ś.d.) | `[DOC] [Rozdz. N]` | ✅ | — | — |
| Wadium | `[DOC] [Rozdz. N]` | ✅ | — | — |
| Pełnomocnictwo | `[DOC] [Rozdz. N]` | — | — | jeśli dotyczy |
| Zobowiązanie podmiotu 3. | `[DOC] [Rozdz. N]` | — | — | jeśli dotyczy |
| Wykaz dostaw | `[DOC] [Rozdz. N]` | — | ✅ | — |
| Wykaz osób | `[DOC] [Rozdz. N]` | — | ✅ | — |
| Oświadczenie grupa kapitałowa | `[DOC] [Rozdz. N]` | — | ✅ | — |
| Oświadczenie o aktualności | `[DOC] [Rozdz. N]` | — | ✅ | — |

## Powiązania

- [[index-<<slug-wykonawcy-1>>]]
- [[index-<<slug-wykonawcy-2>>]]
- [[01-raport-glowny-<<wykonawca>>]]
