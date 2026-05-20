---
title: Few-shot examples — dobry design vs AI slop
purpose: kalibracja Evaluatora; ładowane do kontekstu Evaluatora przy każdej ocenie design
use: assets/rubric-example.md → state/rubric/examples/ przy faza 3
---

# Rubric Few-shot — design & originality

> **Reguła:** bez konkretnych przykładów "dobry vs zły" model produkuje sztampę. Few-shot zmienia średnią jakość oceny o ~30%.

---

## 1. Dobry design — referencje

### Example A — retro-pixel UI (paleta dark + akcent neon)

**Co tu jest dobrze:**
- Paleta 4-kolorowa: `#1a1a2e` (tło), `#16213e` (sekcje), `#0f3460` (separatory), `#e94560` (CTA + akcenty).
- Typografia: `"Press Start 2P"` dla headerów (pixelated), `"IBM Plex Mono"` dla body.
- Brak gradientów. Tła plaskie, akcenty kolorystyczne.
- Spacing: 8px grid, wszystko mnożnik 8.
- Mikrointerakcje: `:hover` zmienia kolor border (1px → 2px), bez transition longer than 100ms.

**Co kontroluje to kryterium binarnie:**
- `getComputedStyle(body).backgroundColor` ∈ `["rgb(26, 26, 46)", "rgb(22, 33, 62)"]`.
- `font-family` headerów zawiera `"Press Start 2P"`.
- Brak `linear-gradient` w `getComputedStyle` 10 losowych elementów.
- Wszystkie marginesy/padding to `Nx8px` (N integer).

### Example B — terminal aesthetic

**Co tu jest dobrze:**
- Mono palette: `#0a0a0a` (tło), `#00ff41` (tekst, "Matrix green"), `#ffffff` (highlights).
- 1 czcionka: `"JetBrains Mono"`.
- Cursor blink przez `animation: blink 1s steps(2, start) infinite`.
- ASCII art dla illustrations.

---

## 2. AI slop — anty-referencje (rozpoznawaj i odrzucaj)

### Anti-A — "futuristic SaaS dashboard"

**Co tu jest źle:**
- `linear-gradient(135deg, #667eea 0%, #764ba2 100%)` — fioletowy gradient. **Klasyczny AI slop.**
- Pływające kolorowe okręgi w tle (`filter: blur(80px)`) — bez funkcji, bez powodu.
- "Empower your workflow with AI" w copy.
- Rocket emoji 🚀 jako bullet point.
- Sans-serif "Inter" + jeszcze 3 inne fonty "for variety".
- Półprzezroczyste karty z `backdrop-filter: blur(10px)` na **stałe** (nie w modalu).

**Co kontroluje to kryterium binarnie:**
- `linear-gradient.*purple|violet|pink|#667eea|#764ba2` → fail.
- `backdrop-filter: blur` na elementach nie-modalnych → fail.
- Słowa kluczowe w copy: `"Empower"`, `"Unlock"`, `"Seamlessly"`, `"Revolutionary"` → fail.
- Emoji w UI (`🚀✨💡🎯`) → fail.
- >2 różne `font-family` w aplikacji → fail.

### Anti-B — "modern minimalist"

**Co tu jest źle:**
- `font-family: Inter, sans-serif` jako default (everyone uses it = no character).
- Karta z `border-radius: 24px` + `box-shadow: 0 20px 40px rgba(0,0,0,0.1)` (generic depth).
- "Hero section" z dużym headerem typu "Welcome to AppName" + 2 CTA buttons (Primary + Secondary).
- Stock illustration z Undraw.co (rozpoznawalne).
- Light/dark mode toggle bez customizacji.

**Co kontroluje:**
- `font-family` zawiera `"Inter"` jako primary i NIE jest jawnie wybrane w kontrakcie → fail (zbyt generic).
- Header z H1 ≥48px + 2 buttony obok siebie + paragraf placeholder → fail (template hero).
- Image src zawiera `undraw.co` → fail.

---

## 3. Granica decyzji — kiedy jest OK, kiedy nie

| Wzorzec | OK gdy | Slop gdy |
|---|---|---|
| Gradient | Kontrakt jawnie go wymaga + paleta zdefiniowana | "Tak ładnie wygląda" |
| Glassmorphism | Modal/overlay (krótkotrwałe) | Na każdej karcie statycznie |
| Sans-serif Inter | Aplikacja inżynierska/techniczna z 1 fontem | Domyślny wybór bez decyzji |
| Emoji w UI | Komunikator/social (kontekst) | Dashboard / settings / lista |
| Hero section | Landing page | Aplikacja produktowa |

---

## 4. Procedura użycia

### Faza 3 (negocjacja)

Evaluator dopisuje do kontraktu sekcję `design_examples`:

```json
{
  "design_examples": {
    "good": ["assets/rubric-example.md#example-a", "assets/rubric-example.md#example-b"],
    "bad": ["assets/rubric-example.md#anti-a", "assets/rubric-example.md#anti-b"],
    "custom_for_this_sprint": ["state/rubric/examples/sprint-2/good-mockup.png"]
  }
}
```

### Faza 4 (ocena)

Evaluator ładuje few-shot do kontekstu PRZED oceną kryterium typu `design`. Bez tego — odrzuca kryterium z `verdict: "ambiguous_criterion"`.

---

## 5. Kalibracja domenowa

Te przykłady są **uniwersalne**. Dla konkretnej domeny dopisz w `state/rubric/examples/`:

- **Retro/pixel:** rubric/examples/retro/good-*.png + bad-*.png
- **Enterprise:** rubric/examples/enterprise/good-*.png + bad-*.png  
- **Game UI:** rubric/examples/game/good-*.png + bad-*.png

Po 3-5 sesji w tej domenie — uaktualnij ten plik o domenowe wymówki/wzorce. Patrz `references/traces-reading.md`.
