# planowanie-wydatkow-it-psp

> Skill Claude Code: krok-po-kroku przygotowanie wniosku finansowego / uzasadnienia wydatku / kosztorysu TCO dla systemu IT KG PSP.

## Co robi

Przekształca surowe dane wejściowe o systemie IT (faktury, subskrypcje, plany rozwoju) w **kompletny wniosek finansowy** zawierający:

1. **Metryczka systemu** (Cz. I materiału).
2. **Pełny kosztorys TCO** w PLN BRUTTO (Cz. III) — z VAT, reverse charge dla usług zagranicznych, kursem NBP, rezerwami.
3. **Klasyfikacja UFP** (Cz. IV) — część → dział → rozdział → § → typ B/M.
4. **8-punktowe uzasadnienie per pozycja** (Cz. X.2) — wymóg MSWiA do POLiOC.
5. **Tabela markdown w układzie XLSX 1:1** z `Propozycja zadań do POLiOC 2027-2031 cz.42.xlsx` (Cz. X.1).
6. **Walidacja** automatycznym skryptem (`scripts/check-cost-plan.sh`).

Główny deliverable: **raport.md** (`raport-<system>-<RRRR-MM-DD>.md`) — kopiujesz sekcję 7 (tabela) do Excela i załączasz raport jako uzasadnienie.

## Kiedy używać

- Wniosek do **POLiOC 2027–2031 cz. 42** (środki obronne 0,15% PKB → klasyfikacja 752/75282) — **tryb A** (domyślny).
- Wniosek do POLiOC podstawowy (środki poza 0,15% → 754/75414) — **tryb B**.
- Wniosek z budżetu KG PSP poza POLiOC (754/75409) — **tryb C**.
- Kosztorys TCO dowolnego systemu IT KG PSP (CEOZO, CEZOL, SOiA, e-learning, inne).

## Kiedy NIE używać

- Sprawozdawczość Rb-28 — skill dotyczy planowania ex ante, nie wykonanego.
- SWZ / OPZ / umowa PZP — użyj skilli z `pzp/`.
- Opinia prawna z wykładnią — użyj `legal/opinie-prawne`.
- Porada finansowa ad hoc bez 8-punktowego uzasadnienia.

## Struktura

```
planowanie-wydatkow-it-psp/
├── SKILL.md                              # 6 faz F1-F6 (≤ 500 linii)
├── README.md                             # ten plik
├── CHANGELOG.md
├── references/
│   ├── katalog-kosztow.md                # Cz. II — 15 sekcji A-O
│   ├── klasyfikacja-budzetowa.md         # Cz. IV — UFP + pułapki
│   ├── przeliczenia-walut-vat.md         # Cz. III.0 — PLN brutto + RC + kurs NBP
│   ├── uzasadnienie-8pkt.md              # Cz. X.2 — schemat 8-punktowy
│   ├── polioc-ramy.md                    # Cz. IX — 7 obszarów + 752/75282
│   ├── male-koszty-checklist.md          # Cz. VII — 19 małych + alokacja A/B/C
│   └── anti-rationalization.md           # 20 wymówek z ripostami
├── scripts/
│   └── check-cost-plan.sh                # walidator POSIX (exit 0/1)
├── templates/
│   ├── raport-skeleton.md                # szkielet raport.md (sekcje 1-9)
│   └── tabela-xlsx-uklad.md              # wzór tabeli XLSX A-L (kopiowanie 1:1 do Excela)
└── tests/fixtures/
    ├── good-plan.md                      # tryb A, kompletny → exit 0 (8 ✔)
    ├── good-plan-tryb-c.md               # tryb C (4-pkt schemat) → exit 0 (6 ✔)
    └── bad-plan.md                       # 8 zaprojektowanych błędów → exit 1 (10 wykrytych)
```

## Test walidatora

```bash
sh scripts/check-cost-plan.sh --plan tests/fixtures/good-plan.md --tryb A
# Exit 0 — ✔ all checks passed (8 ✔)

sh scripts/check-cost-plan.sh --plan tests/fixtures/good-plan-tryb-c.md --tryb C
# Exit 0 — ✔ all checks passed (6 ✔)

sh scripts/check-cost-plan.sh --plan tests/fixtures/bad-plan.md --tryb A
# Exit 1 — ✘ FAILED: 10 błędów
```

## Workflow (skrót)

| Faza | Co | Exit criterion |
|---|---|---|
| **F1 Define** | Metryczka systemu, tryb (A/B/C), podstawa prawna, obszar/podobszar POLiOC | Sekcja 1-3 raport.md bez placeholderów |
| **F2 Catalogize** | Lista pozycji per sekcja Cz. II + alokacja A/B/C + checklist małych kosztów | Sekcja 4 raport.md |
| **F3 Price** | Wycena każdej pozycji w PLN BRUTTO (kurs NBP, VAT/RC, rezerwy) | Sekcja 5 (tabela III.B) raport.md |
| **F4 Classify** | Pełna klasyfikacja UFP per pozycja (część/dział/rozdział/§/B/M); żadnego § 4000 | 5 kolumn klasyfikacji wypełnione |
| **F5 Justify** | 8-punktowe uzasadnienie per pozycja (4-punktowe dla trybu C) | Sekcja 6 raport.md, każda pozycja XLSX |
| **F6 Verify+Ship** | Tabela XLSX A-L, suma G..L = F, walidator exit 0 | Sekcja 7 + 8 + 9 raport.md |

## Materiał źródłowy

`now_skille/materialy_polioc/material_przeliczanie_kosztow.md` (11 części, ~1200 linii) — z weryfikacją aktów prawnych przez `legal/sejm-eli-api` (stan 2026-05-25).

## Wersja

v1.0.1 (2026-05-25)
