---
name: zrodla-urzedowe
type: reference
parent: opinie-prawne
loaded-when: "Faza deep research (R1–R6) — potrzeba dokładnych URL-i, formatów ELI lub operatorów wyszukiwania"
sources:
  - "DOC/since_skill.md §6 (Token budget / Progressive Disclosure — wydzielenie katalogu źródeł do references/)"
  - "DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md §5 (reguła aktywacji L3)"
note: "Treść merytoryczna = katalog oficjalnych publikatorów i baz orzecznictwa RP; struktura referencji wynika z pryncypiów DOC."
---

# Oficjalne źródła prawa polskiego — rozszerzony katalog

## I. Publikatory urzędowe

### Dziennik Ustaw RP
- **URL:** https://dziennikustaw.gov.pl/
- **Wyszukiwanie pozycji:** https://dziennikustaw.gov.pl/DU/rok/<rok>/pozycja/<numer>
- **Rola:** jedyne źródło obowiązywania ustaw i rozporządzeń (art. 88 Konstytucji)

### Monitor Polski
- **URL:** https://monitorpolski.gov.pl/
- **Rola:** uchwały Rady Ministrów, zarządzenia Prezydenta, obwieszczenia

### ELI — European Legislation Identifier (polska implementacja)
- **URL:** https://eli.gov.pl/
- **Format:** `https://eli.gov.pl/eli/DU/<rok>/<poz>/ogl/pol/text.html` (ogłoszenie)
- **Format (tekst jednolity):** `https://eli.gov.pl/eli/DU/<rok>/<poz>/tj/pol/text.html`
- **Rola:** autoryzowane teksty aktów w aktualnym brzmieniu oraz brzmienia historyczne

### Dzienniki urzędowe ministrów
- MSWiA: https://dziennikurzedowy.mswia.gov.pl/
- MF: https://www.gov.pl/web/finanse/dziennik-urzedowy-ministra-finansow
- MON: https://www.gov.pl/web/obrona-narodowa/dziennik-urzedowy-ministra-obrony-narodowej
- MS: https://www.gov.pl/web/sprawiedliwosc/dziennik-urzedowy-ministra-sprawiedliwosci
- (oraz pozostałe — wyszukaj `site:gov.pl dziennik urzędowy <ministerstwo>`)

### Wojewódzkie dzienniki urzędowe
- Katalog: https://www.gov.pl/web/mswia/wojewodzkie-dzienniki-urzedowe
- Wzorzec URL: `https://edziennik.<wojewoda>.gov.pl/`

## II. Narzędzia pomocnicze

### ISAP (Internetowy System Aktów Prawnych — Sejm RP)
- **URL:** https://isap.sejm.gov.pl/
- **Wyszukiwarka:** https://isap.sejm.gov.pl/isap.nsf/search.xsp
- **Uwaga:** narzędzie pomocnicze — **nie jest publikatorem**, ale wygodne do szybkiego odnalezienia aktów i ich historii.

### PPIP — Publiczny Portal Informacji o Prawie
- **URL:** https://ppip.gov.pl/

### RCL — Rządowe Centrum Legislacji
- **URL:** https://www.rcl.gov.pl/
- **Proces legislacyjny:** https://legislacja.rcl.gov.pl/
- **Rola:** projekty ustaw i rozporządzeń, OSR (Ocena Skutków Regulacji), konsultacje

### Sejm RP — druki i stenogramy
- **Druki sejmowe:** https://www.sejm.gov.pl/sejm<nrkadencji>.nsf/druki.xsp
- **Rola:** uzasadnienia projektów (kluczowe dla wykładni celowościowej i historycznej)

## III. Orzecznictwo

### Sąd Najwyższy (SN)
- **Orzecznictwo:** https://www.sn.pl/orzecznictwo/
- **Baza:** https://www.sn.pl/orzecznictwo/SitePages/Baza_orzeczen.aspx
- **Wyszukiwanie:** `site:sn.pl <fraza> sygnatura` lub `site:sn.pl "II CSK 123/23"`

### NSA i WSA — CBOSA
- **Baza:** https://orzeczenia.nsa.gov.pl/
- **Wyszukiwanie:** `site:orzeczenia.nsa.gov.pl <fraza> "art. X"`

### Trybunał Konstytucyjny
- **Wyroki:** https://trybunal.gov.pl/postepowanie-i-orzeczenia/wyroki/
- **Postanowienia:** https://trybunal.gov.pl/postepowanie-i-orzeczenia/postanowienia/

### Portal Orzeczeń Sądów Powszechnych
- **URL:** https://orzeczenia.ms.gov.pl/

### Krajowa Izba Odwoławcza (PZP)
- **URL:** https://www.uzp.gov.pl/kio/orzecznictwo

### TSUE (Curia)
- **URL:** https://curia.europa.eu/juris/
- **Stosuj tylko gdy:** wykładnia prawa UE ma realny wpływ na rozstrzygnięcie

### ETPCz (HUDOC)
- **URL:** https://hudoc.echr.coe.int/
- **Stosuj tylko gdy:** wykładnia EKPC ma realny wpływ na rozstrzygnięcie

## IV. Organy nadzoru i kontroli — komunikaty i stanowiska

### Urząd Zamówień Publicznych (UZP)
- **Opinie:** https://www.uzp.gov.pl/baza-wiedzy/interpretacja-przepisow/opinie-dotyczace-ustawy-pzp

### Urząd Ochrony Danych Osobowych (UODO)
- **Stanowiska:** https://uodo.gov.pl/

### Ministerstwo Finansów — interpretacje podatkowe
- **Baza:** https://eureka.mf.gov.pl/

### Najwyższa Izba Kontroli
- **Raporty:** https://www.nik.gov.pl/kontrole/

### Rzecznik Praw Obywatelskich
- **URL:** https://bip.brpo.gov.pl/

## V. Słowniki operatorów wyszukiwania (Google)

| Operator | Przykład | Efekt |
|----------|----------|-------|
| `site:` | `site:sn.pl` | ograniczenie do domeny |
| `""` | `"art. 431 Pzp"` | fraza dokładna |
| `-` | `dostępność -cyfrowa` | wykluczenie |
| `filetype:` | `filetype:pdf` | typ pliku |
| `inurl:` | `inurl:orzeczenia` | fraza w URL |
| `OR` | `SN OR NSA` | alternatywa |

## VI. Protokół weryfikacji cytatu

Przed umieszczeniem w opinii cytatu przepisu:

1. WebFetch: ELI lub Dz.U. danego aktu
2. Porównanie brzmienia literalnego z cytatem (znak po znaku)
3. Ustalenie **daty** tekstu jednolitego i listy nowelizacji
4. Porównanie z datą istotną dla stanu faktycznego (art. 5 przepisów wprowadzających)
5. W razie wątpliwości — pobranie brzmienia historycznego z ELI

Przed umieszczeniem w opinii cytatu orzeczenia:

1. WebFetch: tekst orzeczenia z bazy organu
2. Weryfikacja sygnatury, daty, składu
3. Sprawdzenie, czy orzeczenie nie zostało zmienione / uchylone (uchwała składu rozszerzonego, wyrok TK)
4. Weryfikacja, czy teza jest aktualna w świetle późniejszej linii orzeczniczej
