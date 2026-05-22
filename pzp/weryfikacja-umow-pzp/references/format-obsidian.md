---
name: format-obsidian
type: reference
parent: weryfikacja-umow-pzp
loaded-when: "Phase 6 (generowanie raportu) — konwencja placeholderów, frontmatter dokumentów, callouts per poziom ryzyka"
sources:
  - "DOC/since_skill.md §6 (Token budget / Progressive Disclosure — wydzielenie formatów do pliku L3)"
  - "DOC/material_skill.md §2 (Process over Prose — deterministyczne formaty zamiast prozy)"
note: "Treść merytoryczna = formaty Obsidian MD dla dokumentów wynikowych; struktura referencji wynika z pryncypiów DOC."
---

## Obsidian MD — wymagane formaty per dokument

### Konwencja placeholder-ów w templatach

| Składnia | Znaczenie |
|----------|-----------|
| `<<nazwa_pola>>` | Placeholder do wypełnienia — wartość z dokumentów / kontekstu / usera |
| `<<opcja1 \| opcja2 \| opcja3>>` | Lista wyborów — agent wybiera jedną opcję (pipe `\|` = OR) |
| `<<...>>` | Dłuższy tekst do uzupełnienia |

**Zasada:** W gotowych dokumentach nie powinno pozostać ŻADNEGO placeholder-a `<<...>>`. Jeśli sekcja nie dotyczy przypadku — usuń ją całkowicie lub oznacz „nie dotyczy" z uzasadnieniem.

### Frontmatter (każdy dokument)

```yaml
---
sygnatura: BL-V.2371.3.2026
postepowanie: "System X dla KG PSP"
zamawiajacy: Komenda Główna Państwowej Straży Pożarnej
wykonawca: WASKO S.A.
data_analizy: 2026-04-22
autor_analizy: claude@kg.straz.gov.pl
typ_dokumentu: raport-glowny
status: draft
tags:
  - pzp/weryfikacja-umowy
  - pzp/sygnatura/BL-V-2371-3-2026
  - pzp/wykonawca/wasko
  - pzp/poziom-ryzyka/R2
---
```

### Callouts według kategorii ryzyka

| Poziom | Callout | Zastosowanie |
|--------|---------|--------------|
| R1 Krytyczne | `> [!danger]` | Uniemożliwia podpisanie, nieważność, sprzeczność z ustawą |
| R2 Istotne | `> [!warning]` | Silne ryzyko sporu / egzekucji, korekta wymagana |
| R3 Umiarkowane | `> [!info]` | Ryzyko interpretacyjne, korekta zalecana |
| R4 Drobne | `> [!note]` | Redakcyjne, do rozważenia |
| Zgodność potwierdzona | `> [!success]` | OK |
| Wymagana analiza prawna | `> [!abstract]` | Do pogłębionej oceny |
| Cytat dosłowny | `> [!quote]` | Zawsze dla cytatów z projektu umowy i dokumentów postępowania |
| Propozycja nowego brzmienia | `> [!success]` | Proponowane brzmienie poprawki |
