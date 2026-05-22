---
name: kg-psp-integration
type: reference
parent: weryfikacja-umow-pzp
loaded-when: "Phase 2–6 na maszynie z vault KG PSP — weryfikacja cytatów Pzp, porównanie z szablonami, obieg parafowania §18, ZTP, integracja z analyzing-pzp-offers/drafting-pzp-letters"
sources:
  - "DOC/since_skill.md §6 (Token budget / Progressive Disclosure)"
  - "DOC/material_skill.md §6 (Grounding in Real Expertise — runbook środowiskowy KG PSP)"
note: "Treść merytoryczna = integracja środowiskowa KG PSP + powiązania między skillami; struktura referencji wynika z pryncypiów DOC."
---

## Integracja z kontekstem KG PSP (`PROJEKTY/PZP/PRAWO/`)

Jeżeli skill jest uruchamiany na maszynie użytkownika z vault KG PSP (katalog bazy normatywnej `{prawo_dir}` — w vault Obsidian zwykle `…/PROJEKTY/PZP/PRAWO/`), wykorzystaj następujące zasoby:

### Weryfikacja cytatów Pzp

- **Plik:** [[D20192019Lj]] (`PROJEKTY/PZP/PRAWO/D20192019Lj.md`) — tekst jednolity ustawy Pzp, Dz.U. 2024 poz. 1320, 11 516 linii, 632 art.
- **Zasada:** każdy cytat art. Pzp w raporcie musi być **literalny** — zweryfikuj przez `Grep` / `Read` w tym pliku przed umieszczeniem w raporcie.

### Porównanie z wewnętrznymi szablonami KG PSP

Standardowe projekty umów w KG PSP bazują na dwóch szablonach (zgodnie z [[index_pzp]]):

- **[[szablon-1-umowa_dostawa]]** (`PROJEKTY/PZP/PRAWO/szablon-1-umowa_dostawa.md`) — wzór umowy dostawy,
- **[[szablon-1-umowa_usluga]]** (`PROJEKTY/PZP/PRAWO/szablon-1-umowa_usluga.md`) — wzór umowy usługi.

W Phase 2 (ekstrakcja wymagań) dodaj do `<output_dir>/wymagania-kontraktowe.md` osobną sekcję „Odstępstwa od szablonu KG PSP":

1. Zidentyfikuj typ umowy (dostawa / usługa) wg przedmiotu zamówienia.
2. Porównaj strukturę projektu umowy (wykaz §) z odpowiednim szablonem.
3. Zanotuj: (a) paragrafy obecne w szablonie, brak w projekcie, (b) paragrafy w projekcie poza szablonem, (c) odstępstwa w treści kluczowych paragrafów.
4. Odstępstwa wymagają uzasadnienia i oznacz je w `05-proponowane-poprawki` jako `P3` / `R2-R3` zależnie od istotności.

**Uwaga:** same szablony KG PSP mogą zawierać pola z publikatorem Pzp do aktualizacji — jeśli szablon cytuje przedawniony publikator (np. `Dz.U. 2019 poz. 2019` bez wskazania tekstu jednolitego), **nie powielaj tego błędu w raporcie** — użyj aktualnego `Dz.U. 2024 poz. 1320 ze zm.`.

### Wewnętrzny obieg parafowania (Regulamin KG PSP § 18)

Zgodnie z § 18 [[regulamin_kg_psp]] projekt umowy **przed podpisaniem** musi zostać zaparafowany przez:

1. **Kierownika komórki organizacyjnej właściwej dla przedmiotu zamówienia** (merytorycznie odpowiedzialnego za treść),
2. **Biuro Prawne KG PSP** (zgodność z Pzp i k.c., ocena ryzyk prawnych),
3. **Biuro Finansów KG PSP** (zgodność finansowa, sprawdzenie wynagrodzenia i płatności).

W `07-wnioski-koncowe` (Pytanie 2 — Status wdrożenia) uwzględnij ten obieg jako 3-stopniową checklistę:

```markdown
### Status wdrożenia (obieg § 18 [[regulamin_kg_psp]])

- [ ] Wszystkie R1 (N) wdrożone w projekcie umowy
- [ ] Parafowanie: kierownik komórki organizacyjnej (<<imię nazwisko>>) — <<data>>
- [ ] Parafowanie: Biuro Prawne KG PSP — <<data>>
- [ ] Parafowanie: Biuro Finansów KG PSP — <<data>>
- [ ] Zaakceptowane przez wykonawcę (jeśli wymaga uzgodnienia)
```

### Zasady redakcji — ZTP

Cytowanie jednostek redakcyjnych zgodnie z [[zasady_redakcji]] (§ 54-63 Zasad techniki prawodawczej):

- **Ustawy / rozporządzenia:** `art. N ust. M pkt K lit. L tiret M`
- **Umowy i akty wewnętrzne:** `§ N ust. M pkt K lit. L` (paragraf zamiast artykułu — konwencja kodeksowa)

## Integracja z istniejącymi skillami

### Powiązanie z `analyzing-pzp-offers`

- **Jeśli** user dostarczył `<analysis_dir>` z raportem wygenerowanym przez `analyzing-pzp-offers`:
  - przeczytaj `03-braki-i-niezgodnosci-<slug>.md` — sprawdź czy są F3a/F3 znaleziska w ofercie, które mogą wpłynąć na treść umowy (poprawa omyłki rachunkowej w ofercie = zmiana ceny w umowie),
  - przeczytaj `06-cytaty-i-zrodla-<slug>.md` — używaj skatalogowanych cytatów dla spójności cytowania,
  - porównaj wnioski z analizy oferty z obecnym stanem projektu umowy — zapis w `04-macierz-korelacji` powinien pokrywać te same punkty, co analiza oferty.
- **Jeśli** `<analysis_dir>` nie istnieje — skill działa samodzielnie, ale w `00-podsumowanie-wykonawcze` odnotuj „brak poprzedniej analizy oferty".

### Powiązanie z `drafting-pzp-letters`

- Po zakończeniu weryfikacji umowy, jeśli wykryto konieczność korekty po stronie wykonawcy (np. dostarczenie uzupełnionych załączników, zgoda na modyfikację klauzuli), **rekomenduj** uruchomienie `drafting-pzp-letters` z odpowiednim typem pisma.
- Typowe sytuacje: wezwanie do zgody na waloryzację, wezwanie do uzgodnienia harmonogramu szczegółowego, zawiadomienie o poprawie omyłki pisarskiej w samej umowie.
