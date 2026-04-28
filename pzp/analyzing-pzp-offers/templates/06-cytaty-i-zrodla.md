---
sygnatura: <<sygnatura>>
postepowanie: "<<nazwa>>"
wykonawca: <<nazwa>>
wykonawca_slug: <<slug-wykonawcy>>
data_analizy: <<yyyy-mm-dd>>
typ_dokumentu: cytaty-i-zrodla
status: <<draft | final>>
liczba_cytatow: <<N>>
tags:
  - pzp/raport
  - pzp/cytaty
  - pzp/sygnatura/<<slug-sygnatury>>
  - pzp/wykonawca/<<slug-wykonawcy>>
---

# Register cytatów i źródeł — Oferta <<wykonawca>>

> [!info] Zasada identyfikacji
> Każdy cytat ma unikalny identyfikator `C-<NNN>` i block ID `^c-<NNN>`. W pozostałych dokumentach odwołuj się przez `[[06-cytaty-i-zrodla-<<slug-wykonawcy>>#^c-001]]`.

## Format wpisu

```markdown
### C-001 — <krótki tytuł>

**Źródło:** `[DOC: <plik>] [Rozdz. N] [ust. N] [pkt N] [lit. l] [str. N]`
**Kategoria:** <wymóg SWZ / stan faktyczny oferty / modyfikacja / karta katalogowa / oświadczenie>
**Cytat:**
> <dosłowny fragment, max 3 zdania>

**Kontekst:** <1 zdanie — czego dotyczy>
**Wykorzystano w:** [[03-braki-i-niezgodnosci#^find-XXX]], [[02-tabela-kontrolna#...]]

^c-001
```

---

## Sekcja 1. Cytaty z dokumentacji postępowania

### Ogłoszenie o zamówieniu

#### C-001 — <<tytuł>>

**Źródło:** `[DOC: <<plik ogłoszenia>>] [pkt <<N>>] [str. <<N>>]`
**Kategoria:** wymóg
**Cytat:**
> <<cytat>>

**Kontekst:** <<...>>
**Wykorzystano w:** [[03-braki-i-niezgodnosci-<<slug-wykonawcy>>#^find-XXX]]

^c-001

### SWZ

#### C-002 — <<tytuł>>

**Źródło:** `[DOC: SWZ_z załącznikami.pdf] [Rozdz. <<N>>] [ust. <<N>>] [pkt <<N>>] [str. <<N>>]`
**Kategoria:** wymóg
**Cytat:**
> <<cytat>>

**Kontekst:** <<...>>
**Wykorzystano w:** <<...>>

^c-002

### OPZ (Załącznik nr 1)

#### C-XXX — <<pkt A/B/C i nazwa>>

**Źródło:** `[DOC: Zał nr 1 do SWZ_OPZ.docx] [Część <<A/B/C>>] [pkt <<N>>] [str. <<N>>]`
**Kategoria:** wymóg techniczny
**Cytat:**
> <<parametr minimalny + kontekst>>

**Kontekst:** <<...>>
**Wykorzystano w:** <<...>>

^c-XXX

### Pisma z wyjaśnieniami i modyfikacjami SWZ

#### C-XXX — <<pismo, data, zakres>>

**Źródło:** `[DOC: <<plik pisma>>] [str. <<N>>]`
**Kategoria:** modyfikacja SWZ
**Cytat:**
> <<...>>

**Kontekst:** <<co modyfikuje, zakres zmian>>
**Wykorzystano w:** <<...>>

^c-XXX

### Załączniki do SWZ

#### C-XXX — <<Zał. nr / nazwa>>

<<...>>

---

## Sekcja 2. Cytaty z oferty wykonawcy

### Formularz oferty (Zał. 3)

#### C-XXX — <<cena / gwarancja / termin>>

**Źródło:** `[DOC: Zał nr 3 do SWZ_Formularz Oferty_<<wykonawca>>_sig.pdf] [str. <<N>>]`
**Kategoria:** stan faktyczny oferty
**Cytat:**
> <<...>>

**Kontekst:** <<...>>
**Wykorzystano w:** <<...>>

^c-XXX

### OPZ wypełniony

#### C-XXX — <<...>>

<<...>>

### Karty katalogowe / dokumentacja techniczna

#### C-XXX — <<...>>

<<...>>

### JEDZ

#### C-XXX — <<sekcja JEDZ>>

<<...>>

### Oświadczenia i pełnomocnictwa

#### C-XXX — <<Zał. 9 / Zał. 10 / Pełnomocnictwo / uzasadnienie tajemnicy>>

<<...>>

### Wadium

#### C-XXX — <<...>>

<<...>>

---

## Sekcja 3. Odniesienia prawne

### Ustawa Pzp

#### R-001 — art. 226 ust. 1 pkt 5 Pzp

**Źródło:** ustawa z 11.09.2019 r. — Prawo zamówień publicznych (tekst jednolity: **Dz.U. 2024 poz. 1320** z późn. zm. — nowelizacje: 2025 r. poz. 620, 769, 794, 1165, 1173, 1235; 2026 r. poz. 252)
**Treść:**
> Zamawiający odrzuca ofertę, jeżeli: (…) 5) jej treść jest niezgodna z warunkami zamówienia.

**Wykorzystano w:** [[03-braki-i-niezgodnosci-<<slug-wykonawcy>>#^find-XXX]]

^r-001

> [!info] Aktualność cytowania
> **Przed cytowaniem ZAWSZE sprawdź aktualny tekst jednolity** w ISAP lub u zamawiającego. Stan na 2026-03-30: Dz.U. 2024 poz. 1320 jest tekstem jednolitym, z nowelizacjami do Dz.U. 2026 poz. 252. Nie używać przedawnionej sygnatury Dz.U. 2023 poz. 1605.
>
> **UWAGA — nowelizacja wchodząca 12.07.2026 r.** (Dz.U. 2025 poz. 1235): certyfikacja wykonawców. Dodaje art. 128a, zmienia art. 112 ust. 3, art. 124 ust. 2–4, art. 273 ust. 2. Przy analizach postępowań wszczętych po tej dacie uwzględnij nowe przepisy.

### Rozporządzenia wykonawcze

#### R-0NN — <<tytuł rozporządzenia>>

<<...>>

### Orzecznictwo KIO (pomocnicze)

#### R-0NN — wyrok KIO z <<data>>, sygn. <<KIO NNNN/RR>>

**Teza:**
> <<parafraza/cytat>>

**Wykorzystano w:** <<...>>

^r-0NN

---

## Spis treści cytatów (index by ID)

| ID | Tytuł | Źródło | Kategoria | Wykorzystanie |
|----|-------|--------|-----------|---------------|
| C-001 | <<...>> | <<...>> | <<...>> | <<#^find-XXX>> |
| C-002 | <<...>> | <<...>> | <<...>> | <<...>> |
| ... | ... | ... | ... | ... |
| R-001 | art. 226 ust. 1 pkt 5 Pzp | ustawa Pzp | podstawa prawna | <<...>> |

## Spis treści dokumentów cytowanych (index by file)

| Plik | Liczba cytatów | ID cytatów |
|------|----------------|------------|
| SWZ_z załącznikami.pdf | <<N>> | C-002, C-003, ... |
| Zał nr 1 do SWZ_OPZ.docx | <<N>> | C-0NN, ... |
| Oferta_KG PSP.pdf | <<N>> | C-0NN, ... |
| ... | ... | ... |

## Powiązania

- [[01-raport-glowny-<<slug-wykonawcy>>]]
- [[02-tabela-kontrolna-<<slug-wykonawcy>>]]
- [[03-braki-i-niezgodnosci-<<slug-wykonawcy>>]]
- [[04-analiza-szczegolowa-<<slug-wykonawcy>>]]
- [[05-ocena-ryzyka-<<slug-wykonawcy>>]]
