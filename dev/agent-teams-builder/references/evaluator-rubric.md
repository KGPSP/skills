---
title: Rubryka ewaluatora — 4 filary, twarde progi, kalibracja few-shot
load-when: "Faza 4 SKILL.md — Evaluator zaczyna ocenę sprintu"
source:
  - DOC/agent-teams-generator-ewaluator.md §4 (Rubryka ewaluatora)
  - DOC/material_skill.md §4 (Definition of Done — dowód zamiast deklaracji)
  - DOC/since_skill.md §2 (Filar 3: Non-negotiable Verification)
---

# Rubryka ewaluatora

> Sekret skuteczności Evaluatora **nie siedzi w modelu**, siedzi w jakości jego rubryki. Słaba rubryka + Opus = słaba ocena. Surowa rubryka + Sonnet = dobra ocena.

---

## 1. Cztery filary oceny

| Filar | Co ocenia | Waga dla Opus 4.7+ | Waga dla Sonnet/Haiku |
|---|---|---|---|
| **Design** | Estetyka, layout, typografia, palety | 30% | 20% |
| **Originality** | Czy to nie jest "AI slop"? Czy ma charakter? | 25% | 15% |
| **Craft** | Czystość kodu, czytelność, brak stubów | 20% | 30% |
| **Functionality** | Czy faktycznie działa? | 25% | 35% |

**Reguła:** dla mocniejszych modeli (Opus 4.7+) funkcjonalność jest "wykonywana z palca" — kładziemy nacisk na Design i Originality. Dla słabszych — odwrotnie.

Per warstwa można mieć **osobne rubryki** (`rubric/api-design.md`, `rubric/code-quality.md`) ładowane progresywnie. Nie pakuj wszystkiego w jeden plik.

---

## 2. Cztery zasady budowy rubryki

### 2.1 Ekstremalna granularność

- Pojedyncza funkcja → ≥15 punktów. W cytowanym projekcie Anthropic — 27.
- Rozmyte kryterium ("kod jest czytelny") → model je ignoruje.
- Granulacja na poziomie pojedynczej interakcji UI: "klik prawym myszą otwiera menu kontekstowe z 4 pozycjami w kolejności: X, Y, Z, W".

### 2.2 Kodyfikacja "dobrego smaku"

Estetyka **da się ocenić** przez AI — pod warunkiem że masz sprecyzowaną wizję opisaną sztywnymi regułami:

✅ Dobre kryterium:
> "Tło aplikacji używa palety #1a1a2e / #16213e / #0f3460 (dark retro). Brak gradientów liniowych. Akcenty: #e94560. Heatmapa kolorów na screenshocie pokazuje ≥80% pikseli w tych odcieniach."

❌ Słabe kryterium:
> "Kolory są przyjemne dla oka."

### 2.3 Kalibracja przykładami (few-shot)

Rubryka MUSI zawierać sekcję `examples/` z 2-4 referencjami:

- `examples/good-design.png` + opis dlaczego (paleta, typografia, brak slop).
- `examples/ai-slop.png` + opis dlaczego (fioletowy gradient, "Lorem Ipsum cards", emoji rocket 🚀, "futuristic" sans-serif).
- `examples/good-code.ts` + komentarz dlaczego (DAMP, named exports, brak `any`).
- `examples/bad-code.ts` + komentarz (zagnieżdżone `any`, magic numbers, `if (true)` martwy).

**Bez few-shot** model produkuje sztampę. Few-shot zmienia średnią jakość o ~30%.

### 2.4 Twarde progi binarne — NIE skale 1-10

Modele osiadają na "7/10" i przepuszczają niestabilny kod. Stosuj progi binarne:

✅ Dobre:
- `Zero błędów TypeScript (tsc --noEmit exit 0)`
- `Zero stubów w `src/feature/` (grep -E "TODO|FIXME|throw.*not implemented" zwraca 0)`
- `Wszystkie 12 testów Playwright zielone`
- `Zero console.error w trace runtime`

❌ Złe:
- `Jakość kodu: 8/10`
- `Design wygląda dobrze`
- `Funkcjonalność prawie kompletna`

---

## 3. Kryteria per warstwa (przykłady operacyjne)

### 3.1 Funkcjonalność — granularna, sprawdzalna

| Kryterium | Sprawdź |
|---|---|
| **Kolejność tras API** (przechodzi CI, łamie produkcję) | `curl /api/v1/X` z mock 401 → `/api/v1/login` → ponowne `X` → 200. Trace w `state/evidence/` |
| **Fizyczne testy klawiatury** | `playwright.keyboard.press('Space')` faktycznie wywołuje akcję. Screenshot pre/post. |
| **Boolean logic edge cases** | Generator zwykle pomija. Wymuś: pusty input, `null`, `undefined`, `[]`, `{}`, 0, `false`, `""`. |
| **Race conditions** | Dwa równoległe POST → idempotencja LUB jawny conflict 409. |
| **Persistence** | F5 / restart → stan z localStorage / DB. |

### 3.2 Layout (wizualne błędy)

| Kryterium | Sprawdź |
|---|---|
| **Brak nakładającego się tekstu** | `playwright.locator(A).boundingBox() ∩ locator(B).boundingBox() === ∅` dla wszystkich par tekstowych |
| **Responsywność** | Screenshot na 1920×1080, 1366×768, 375×667 — żaden element nie wychodzi poza viewport |
| **Loading states** | Każda asynchroniczna akcja ma spinner LUB skeleton. Brak białego ekranu >200ms. |
| **Empty states** | Pusta lista wyświetla `EmptyState` komponent, nie `null`. |

### 3.3 Architektura i jakość kodu

| Kryterium | Sprawdź |
|---|---|
| **Brak stubów** | `grep -rE "TODO\|FIXME\|XXX\|throw new Error\('not implemented'\)" src/feature/` zwraca 0 linii |
| **Brak `any`** | `tsc --noImplicitAny --strict exit 0` |
| **PR size** | `git diff --stat` ≤300 linii (lub uzasadniony split) |
| **Testy obecne** | Beyoncé Rule: każdy publiczny export ma test. Heurystyka: `git diff --name-only HEAD~N..HEAD` na plikach `src/*` ma odpowiadające `tests/*` |
| **Hyrum check** | Brak modyfikacji istniejących sygnatur publicznych bez ADR w `docs/adr/` |

### 3.4 Design i originality

| Kryterium | Sprawdź |
|---|---|
| **Brak AI slop** | Heurystyka: brak `linear-gradient(.*purple\|violet\|pink)`, brak `🚀\|✨\|💡` w UI, brak "Empower your...", "Unlock the power of..." w copy |
| **Spójna paleta** | Top 5 kolorów na screenshocie ∈ zdefiniowanej palecie (z few-shot examples) |
| **Typografia** | `font-family` zgodny z few-shot (np. "Inter" + "JetBrains Mono", NIE "Roboto" jako default) |
| **Mikrointerakcje** | Każdy przycisk ma `:hover` + `:active` state. Brak skoków layoutu. |

---

## 4. Format zapisu wyniku oceny

Evaluator nie zwraca prozy, zwraca **strukturę JSON** dopisywaną do kontraktu:

```json
{
  "iteration": 3,
  "ts": "2026-05-19T17:30:00Z",
  "criteria_results": [
    { "id": "C-01", "passed": true, "evidence_path": "state/evidence/sprint-2/C-01.png" },
    { "id": "C-02", "passed": false, "evidence_path": "state/evidence/sprint-2/C-02.log", "observation": "POST /save zwraca 500 przy pustym tytule" }
  ],
  "summary": { "passed": 14, "failed": 1, "total": 15 },
  "verdict": "iterate",
  "pivot_recommended": false,
  "feedback_for_generator": "Kryterium C-02: zapis bez tytułu powinien być walidowany na froncie, nie powodować 500 z backendu. NIE podaję rozwiązania."
}
```

**Reguła:** `feedback_for_generator` opisuje **co nie działa**, NIE **jak naprawić**. Generator sam szuka rozwiązania.

---

## 5. Aktywne testowanie — co Evaluator faktycznie robi

Evaluator **nie czyta diffów**. Evaluator otwiera aplikację:

1. **Playwright MCP** → web apps. Klika, robi screenshots, czyta DOM, mierzy timing.
2. **Chrome DevTools MCP** → szczegółowa analiza perf, network, console errors.
3. **Computer Use** → aplikacje desktopowe natywne.
4. **playwright CLI** → reprodukowalne scenariusze (`playwright test smoke.spec.ts`).
5. **Bash + curl** → smoke testy API.

**Generator NIE MA dostępu do tych narzędzi.** Inaczej testuje własny kod = sędzia we własnej sprawie.

---

## 6. Hill climbing — jak działa pętla

Ewaluator wywiera **ciągłą presję**, generator iteruje aż osiągnie próg:

```
iteration 1: passed 8/15  → feedback do Generatora → fix
iteration 2: passed 11/15 → feedback                → fix
iteration 3: passed 13/15 → feedback                → fix
iteration 4: passed 14/15 → feedback                → fix
iteration 5: passed 14/15 → STAGNACJA              → pivot? Patrz pivot-protocol.md
```

**Progres na rubryce** = `passed` rośnie monotonicznie. Brak progresu przez 2 iteracje z rzędu = sygnał do pivota.

---

## 7. Walidacja samej rubryki

Przed wejściem w fazę 4 uruchom:

```bash
scripts/verify-evaluator-rubric.sh state/contracts/sprint-{n}.json
# sprawdza:
#   - liczbę kryteriów ≥15
#   - 100% kryteriów ma binary: true
#   - 0 kryteriów typu "skala", "ocena 1-10", "good/bad/ok"
#   - sekcja examples/ ma min. 2 referencje "good" i 2 "bad"
#   - każde kryterium ma określony `evidence_type`
```

Brak exit 0 = brak prawa na ocenę. Wracaj do fazy 3.
