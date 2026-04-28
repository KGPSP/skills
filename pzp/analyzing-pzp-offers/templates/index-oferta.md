---
sygnatura: <<sygnatura>>
postepowanie: "<<nazwa>>"
zamawiajacy: <<zamawiajacy>>
wykonawca: <<pełna nazwa wykonawcy>>
wykonawca_slug: <<slug-wykonawcy>>
nip: <<nip>>
regon: <<regon>>
krs: <<krs>>
status_msp: <<mikro | małe | średnie | duże>>
data_zlozenia_oferty: <<yyyy-mm-dd>>
cena_brutto: <<kwota>>
cena_netto: <<kwota>>
vat: <<kwota>>
okres_gwarancji_miesiace: <<N>>
termin_realizacji: <<data>>
id_oferty_platforma: <<id>>
podmiot_udostepniajacy_zasoby: <<jeśli dotyczy>>
typ_dokumentu: indeks-oferty
data_utworzenia: <<yyyy-mm-dd>>
tags:
  - pzp/indeks
  - pzp/oferta
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/wykonawca/<<slug-wykonawcy>>
---

# Indeks dokumentów — Oferta <<pełna nazwa wykonawcy>>

> [!info] Meta oferty
> - **Postępowanie:** <<nazwa>>
> - **Nr sprawy:** <<sygnatura>>
> - **Zamawiający:** <<zamawiajacy>>
> - **Wykonawca:** <<nazwa, forma prawna, adres>>
> - **NIP:** <<nip>> | **REGON:** <<regon>> | **KRS/CEiDG:** <<krs>>
> - **Status MŚP:** <<status>>
> - **Data złożenia oferty:** <<yyyy-mm-dd hh:mm>>
> - **Cena brutto:** ==<<kwota>>==
> - **Cena netto:** <<kwota>>
> - **VAT:** <<kwota>>
> - **Oferowany okres gwarancji:** ==<<N>> miesięcy==
> - **ID oferty na platformazakupowa.pl:** <<id>>
> - **Podmiot udostępniający zasoby:** <<nazwa lub „nie dotyczy">>

---

## Dokumenty w katalogu głównym oferty

### <<nazwa pliku>>

<<Opis pliku: tytuł właściwy, funkcja w ofercie, rozmiar (strony), podpisy, kluczowe treści. Dla wadium — kwota, nr gwarancji/transakcji, wystawca, beneficjent, termin ważności. Dla pełnomocnictwa — nr, osoba upoważniona, zakres.>>

---

## Część jawna <<nazwa wykonawcy>>

### <<metadane.xml>>

<<Metadane oferty z platformazakupowa.pl: identyfikacja wykonawcy, osoba składająca, adres e-mail, spis załączników oferty z sumami kontrolnymi SHA-256.>>

### <<Formularz Oferty ... sig.pdf>>

<<Nr dokumentu, stron, treść kluczowa (cena, gwarancja, termin), status wykonawcy, podpis elektroniczny, konto bankowe do zwrotu wadium.>>

### <<JEDZ ... sig.pdf>>

<<Jednolity Europejski Dokument Zamówienia: zakres sekcji (II–VI), czy PDF obraz czy XML, czy podpisany, przez kogo.>>

### <<OPZ_wypełniony ... sig.pdf>>

<<Opis Przedmiotu Zamówienia jako przedmiotowy środek dowodowy: ile stron, czy obejmuje wszystkie części (A, B, C), które parametry potwierdzono. Wskazanie czy karty katalogowe zastrzeżono jako tajemnicę przedsiębiorstwa.>>

### <<Zobowiązanie podmiotu trzeciego>>

<<Jeśli dotyczy: podmiot trzeci, rodzaj stosunku (umowa podwykonawcza / inne), zakres zasobów udostępnianych, okres udziału.>>

### <<Oświadczenia sankcyjne Zał. 9, Zał. 10>>

<<Art. 5k rozp. 833/2014 + art. 7 ust. 1 ustawy antyrosyjskiej. Czy obejmuje wykonawcę, podwykonawcę, dostawcę >10%, podmiot trzeci. Osoba reprezentująca.>>

### <<Wadium / gwarancja wadialna>>

<<Forma (pieniądz / gwarancja bankowa / ubezpieczeniowa / poręczenie), kwota, numer, wystawca, beneficjent, termin ważności, nieodwołalność, sygnatura postępowania w tytule.>>

### <<Uzasadnienie tajemnicy przedsiębiorstwa>>

<<Jeśli dotyczy: które dokumenty zastrzeżono, jak uzasadniono 3 przesłanki (art. 18 ust. 3 Pzp + art. 11 ust. 2 uznk), czy przywołano orzecznictwo KIO.>>

---

## Część niejawna <<wykonawca>> (tajemnica przedsiębiorstwa)

> [!warning] Tajemnica przedsiębiorstwa
> Zawartość zastrzeżona — w raporcie cytować tylko fragmenty niezbędne do oceny i oznaczać „TAJEMNICA PRZEDSIĘBIORSTWA".

### Część <<A/B/C>> — <<nazwa części OPZ>>

#### <<pkt OPZ np. A.1 — Węzły obliczeniowe>>

- **<<nazwa pliku>>** — <<krótki opis karty katalogowej / dokumentu: model, producent, rola w rozwiązaniu>>
- **<<nazwa pliku>>** — <<...>>

#### <<pkt OPZ np. A.2 — Compute fabric>>

- **<<nazwa pliku>>** — <<...>>

### Karty katalogowe pomocniczych urządzeń

#### <<grupa np. Agregat + ATS>>

- **<<nazwa pliku>>** — <<producent, model, parametry>>

---

## Pozostałe artefakty

### <<nazwa>>.XAdES / .sig / .p7s

<<Kwalifikowany podpis elektroniczny zewnętrzny: jakie archiwum lub plik podpisuje, czy integralność zachowana.>>

---

## Zestawienie podsumowujące

| Parametr | Wartość |
|----------|---------|
| Wykonawca | <<nazwa>> |
| NIP | <<nip>> |
| KRS | <<krs>> |
| Status MŚP | <<status>> |
| Cena brutto | ==<<kwota>>== |
| Cena netto | <<kwota>> |
| VAT | <<kwota>> |
| Okres gwarancji | <<N>> miesięcy |
| Termin realizacji | <<data>> |
| Wadium | <<kwota>> — <<forma>> (nr <<nr>>, ważne do <<data>>) |
| Podmiot udost. zasoby | <<nazwa lub „nie dotyczy">> |
| Reprezentacja w ofercie | <<osoba + funkcja>> |
| Architektura / kluczowi dostawcy | <<marki / producenci / podwykonawcy >10%>> |

## Statystyka plików

| Kategoria | Liczba plików | Łączny rozmiar |
|-----------|---------------|----------------|
| Część jawna | <<N>> | <<MB>> |
| Część niejawna | <<N>> | <<MB>> |
| Wadium | <<N>> | <<MB>> |
| Metadane / podpisy | <<N>> | <<KB>> |
| **Razem** | **<<N>>** | **<<MB>>** |

## Powiązania

- [[index-ogloszenie]]
- [[00-podsumowanie-wykonawcze-<<slug-wykonawcy>>]]
- [[01-raport-glowny-<<slug-wykonawcy>>]]
- [[02-tabela-kontrolna-<<slug-wykonawcy>>]]
