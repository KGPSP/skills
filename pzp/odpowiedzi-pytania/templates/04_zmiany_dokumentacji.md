---
sygnatura_postepowania: <<sygnatura>>
postepowanie: "<<krótka nazwa>>"
zamawiajacy: <<np. Komenda Główna Państwowej Straży Pożarnej>>
data_wyjasnien: <<RRRR-MM-DD>>
typ_dokumentu: zmiany-dokumentacji
status: draft
autor: claude@kg.straz.gov.pl
liczba_zmian: <<N>>
wymaga_zmiany_ogloszenia: <<tak | nie>>
wymaga_przedluzenia_terminu: <<tak | nie>>
nowy_termin_skladania: <<RRRR-MM-DD HH:MM | brak zmiany>>
podstawa_prawna_zmian:
  - "art. <<137 | 286>> ustawy z dnia 11 września 2019 r. — Prawo zamówień publicznych (Dz.U. 2024 poz. 1320 ze zm.)"
tags:
  - pzp/wyjasnienia
  - pzp/sygnatura/<<sygnatura w slug>>
  - pzp/etap/zmiany-dokumentacji
---

> [!info] Wykaz zmian dokumentacji
> Zbiorczy wykaz zmian SWZ / OPZ / projektu umowy / formularzy / załączników / ogłoszenia wprowadzanych w wyniku odpowiedzi na pytania wykonawców. Powiązane: [[02_analiza_hipotez]], [[03_odpowiedzi_dla_wykonawcow]], [[05_raport_ryzyk]], [[06_wersja_do_akceptacji]].

# Wykaz zmian dokumentacji — `<<sygnatura>>`

**Tura wyjaśnień:** <<N>>
**Data:** <<RRRR-MM-DD>>
**Liczba zmian:** <<N>>

## Podsumowanie zbiorcze

| # | Dokument | Jednostka | Wynika z pytania | Wpływ na termin | Wymaga zmiany ogłoszenia |
| --- | --- | --- | --- | --- | --- |
| 1 | <<np. SWZ>> | <<np. rozdz. VIII pkt 1.1>> | Q<<N>> | <<TAK \| NIE>> | <<TAK \| NIE>> |
| 2 | <<np. OPZ>> | <<np. pkt A.1>> | Q<<N>> | <<TAK \| NIE>> | <<TAK \| NIE>> |
| 3 | <<np. Projekt umowy>> | <<np. § 6 ust. 1 lit. a>> | Q<<N>> | <<TAK \| NIE>> | <<TAK \| NIE>> |

## Zbiorczy skutek dla terminu składania ofert

> [!warning] **<<TAK | NIE>>** — termin składania ofert <<wymaga przedłużenia | pozostaje bez zmian>>.

<<jeżeli TAK:>>

- **Pierwotny termin składania ofert:** <<RRRR-MM-DD HH:MM>>
- **Nowy termin składania ofert:** <<RRRR-MM-DD HH:MM>>
- **Minimalna liczba dni przedłużenia:** <<N>> dni
- **Podstawa prawna:** <<art. 137 ust. 6 ustawy Pzp (≥ progi) | art. 286 ust. 3 ustawy Pzp (< progi)>>
- **Uzasadnienie:** <<dlaczego konieczne — np. zmiana parametru OPZ poszerza krąg wykonawców>>
- **Wymaga aktualizacji ogłoszenia w BZP/TED?** <<TAK \| NIE>>

---

## Zmiana #1 — wynika z odpowiedzi na pytanie nr <<N>>

**Dokument:** <<SWZ | OPZ | Załącznik nr X do SWZ | Projekt umowy / PPU | Formularz ofertowy | Ogłoszenie>>
**Jednostka redakcyjna:** <<rozdział X.Y / § N ust. M / pkt N lit. a>>

**Dotychczasowe brzmienie:**

> „<<cytat>>"

**Nowe brzmienie:**

> „<<cytat>>"

**Uzasadnienie zmiany:**

<<1–3 zdania merytoryczne — np. doprecyzowanie kryteriów równoważności w celu rozszerzenia konkurencji bez naruszenia funkcjonalności rozwiązania>>

**Wpływ na inne dokumenty postępowania:**

- [ ] SWZ — <<dotyczy/nie dotyczy>>
- [ ] OPZ — <<…>>
- [ ] Projekt umowy — <<…>>
- [ ] Formularz ofertowy — <<…>>
- [ ] Załączniki techniczne — <<…>>

**Wpływ na termin składania ofert:** <<TAK — przedłużenie do <<RRRR-MM-DD>> | NIE>>
**Wymaga zmiany ogłoszenia:** <<TAK — Sekcja <<N>> | NIE>>
**Podstawa prawna zmiany:** <<art. 137 ust. <<N>> | art. 286 ust. <<N>>>>

---

## Zmiana #2

<!-- powtórz strukturę dla każdej zmiany -->

---

## Zmiana ogłoszenia (jeśli wymagana)

> [!important] Jeżeli choć jedna zmiana wymaga zmiany ogłoszenia w BZP / TED — wypełnij tę sekcję. Termin publikacji zmiany ogłoszenia **musi być wcześniejszy lub równy** publikacji wyjaśnień + zmiany SWZ.

| Sekcja ogłoszenia | Dotychczasowe brzmienie | Nowe brzmienie |
| --- | --- | --- |
| <<np. II.2.7) — termin realizacji>> | „<<cytat>>" | „<<cytat>>" |
| <<np. III.1.3) — zdolność techniczna>> | „<<cytat>>" | „<<cytat>>" |
| <<np. IV.2.2) — termin składania ofert>> | <<RRRR-MM-DD>> | <<RRRR-MM-DD>> |

**Wymagana procedura publikacji:**
1. Komunikat o zmianie ogłoszenia w BZP/TED — przed publikacją zmiany SWZ.
2. Publikacja zmiany SWZ na stronie postępowania (platforma zakupowa).
3. Publikacja wyjaśnień (`03_odpowiedzi_dla_wykonawcow.md`).

## Lista plików do wytworzenia poza skill-em

- [ ] Komunikat o zmianie SWZ (`Zmiana_SWZ_<<RRRR-MM-DD>>.docx`) — pełne brzmienie zmienionego dokumentu z naniesionymi zmianami.
- [ ] Komunikat o zmianie ogłoszenia (jeśli dotyczy).
- [ ] Aktualizacja platformy zakupowej (terminy, dokumenty).

## Spójność z istniejącą dokumentacją (kontrola)

- [ ] Czy zmiana w SWZ rozdz. X.Y nie generuje sprzeczności z OPZ?
- [ ] Czy zmiana w OPZ pkt A.1 jest spójna z formularzem cenowym?
- [ ] Czy zmiana w projekcie umowy § N nie pozostaje w sprzeczności z OPZ?
- [ ] Czy zmiana terminu realizacji jest spójna z terminem składania ofert + terminem zawarcia umowy + terminem realizacji + terminem dofinansowania (jeżeli dotyczy)?
- [ ] Czy nowe brzmienie zachowuje numerację jednostek redakcyjnych zgodnie z ZTP (`references/prawo-index.md` → „Zasady redakcji")?
