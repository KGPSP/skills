---
name: dynamic-workflows-standard
type: reference
parent: audited-feature-workflow
sources:
  - DOC/dynamic_workflows-cc.md
  - "https://code.claude.com/docs/en/workflows"
  - "https://code.claude.com/docs/en/model-config"
description: Standard wykorzystania Dynamic Workflows + mapowanie effort/ultrathink/ultracode na poziomie analizy i orkiestracji w audited-feature-workflow. Ładuj warunkowo (Phase 0/1 dla M/L lub trigger workflow|ultracode; Phase 8 audyt na skalę).
---

# Dynamic Workflows — standard orkiestracji (Phase 0/1+)

> [!quote] Źródło (Claude Code v2.1.154+)
> „Orchestrate subagents at scale with dynamic workflows" — https://code.claude.com/docs/en/workflows
> Lokalny kanon: [DOC/dynamic_workflows-cc.md](../../../DOC/dynamic_workflows-cc.md) (§1–§14).

## 1. Czym są (potwierdzone z docs CC)

- **Dynamic Workflow** = skrypt JavaScript generowany przez Claude'a, wykonywany w tle przez runtime, orkiestrujący **dziesiątki–setki subagentów** (cap 16 concurrent, 1000 total/run).
- **Plan przenosi się z kontekstu do kodu** (zmienne runtime) → brak degradacji kontekstu, **wznawialność** (resume/checkpointing), adwersaryjna weryfikacja krzyżowa.
- Prymitywy: `agent()`, `parallel()` (bariera), `pipeline()` (bez bariery — domyślny), `phase()`, `log()`, `schema` (StructuredOutput), `budget`.

## 2. Effort & Thinking — mapowanie na mechanizmy CC

> **Kanon = `/effort`** (pewny, potwierdzony w docs CC/API). `ultrathink`/`ultracode` to affordances Claude Code **CLI zależne od wersji** — używaj z fallbackiem na `/effort`. NIE zakładaj dostępności komendy bez weryfikacji w swojej sesji.

| Mechanizm | Co robi | Jak włączyć | Status |
|---|---|---|---|
| **/effort** | poziom rozumowania `low`/`medium`/`high`/`xhigh`/`max` (`high` = domyślny) | `/effort <poziom>`, `effortLevel` w settings.json, `--effort`, env `CLAUDE_CODE_EFFORT_LEVEL` | **potwierdzony kanon** |
| **ultrathink** | maksymalny budżet rozumowania (`think` < `think hard` < `think harder` < `ultrathink`) | słowo `ultrathink` w prompcie (CLI) | keyword CLI (przywrócony ~v2.1.68); **nie API/web** → fallback `/effort max` |
| **ultracode** | `xhigh` effort + automatyczna orkiestracja workflows per zadanie | `/effort ultracode` (per-sesja; powrót `/effort high`) | opisany w DOC §5.3 i menu `/effort`; **dostępność zależna od wersji** → alias `/effort xhigh\|max` + orkiestracja |

> [!warning] Status terminów (uczciwość źródeł)
> `xhigh`/`max` wymagają wspieranego modelu (np. Opus 4.7/4.8). `ultrathink` nie działa w claude.ai/web ani bezpośrednio w API — to keyword Claude Code CLI. Dla `ultracode` dokładna składnia/dostępność **nie była weryfikowana zewnętrznie w tej sesji**; anchory URL pochodzą z researchu. Reguła Anti-Rationalization: nie wpisuj zmyślonej komendy jako jedynej ścieżki — zawsze podaj fallback `/effort`.

## 3. Standard dla tego skilla

- **Phase 1 (Deep Analysis) — DOMYŚLNIE max budżet rozumowania**: `/effort max` (kanon) + keyword `ultrathink` jeśli dostępny. Architecture walk + Hyrum + Chesterton wyznaczają sufit jakości w dół strumienia. Dla **S** (express-mode) dopuszcza zwykły effort.
- **M/L lub wieloskładnikowe → orkiestracja przez Dynamic Workflows.** Fan-out czytelników per podsystem (`parallel`/`pipeline`), synteza w jednym agencie. To **standard, nie opcja**, gdy analiza obejmuje wiele plików/warstw (reguła decyzyjna DOC §3: **>5 równoległych procesów badawczych** lub wolumen > okno kontekstu lub wymóg powtarzalności/audytu).
- **Opcjonalnie `/effort ultracode`** na całą sesję senior-grade — Claude sam decyduje o workflowach per faza (understand → implement → review).
- **Kiedy NIE workflow** (docs CC): praca w 1–2 turach; potrzebny mid-run user input; bardzo ograniczony budżet tokenów; zadanie to proste instrukcje (użyj zwykłych Agentów/edycji).

> [!danger] Workflows a bramki HITL — twarda reguła
> Workflows **NIE wspierają mid-run user input**. Bramki **APPROVAL #1–#5** oraz **/goal Gate #1.5** MUSZĄ pozostać POZA workflowem. Orkiestruj wyłącznie fazy bez-approvalowe (analiza, research, testy, review-findings); w bramkach wracaj do pętli głównej po jawną zgodę. **`/goal` jest wzajemnie wykluczający z Dynamic Workflows / `ultracode`** (Phase 5.8 hard stop). Workflow ≠ obejście HITL. W strefie `--fragile` workflows zakazane (Plan-Validate-Execute wymaga dosłownego wykonania).

## 4. Wzorce wykonawcze (z DOC/dynamic_workflows-cc.md)

- `pipeline()` domyślnie; `parallel()` tylko gdy potrzebny barrier (dedup / early-exit / cross-item).
- **Adwersaryjna weryfikacja**: N niezależnych sceptyków per znalezisko (Phase 1 Hyrum/Chesterton, Phase 8 Five-Axis) — wzmocnienie, nie zamiennik bramek.
- **Loop-until-dry** dla nieznanej liczby znalezisk; **completeness critic** na końcu.
- **Granulacja modeli** (DOC §11): tańszy model do parsowania, mocny do syntezy/review.
- `schema` (StructuredOutput) gdy agent zwraca dane do dalszego przetwarzania.

## 5. Integracja z fazami

| Faza | Użycie Dynamic Workflows |
|---|---|
| 0 | Detekcja size + trigger `workflow`/`ultracode` → flaga „orchestration" (informacyjna, poza gate 6/6). |
| 1 | `/effort max` + ultrathink; M/L → fan-out czytelników per podsystem + synteza. |
| 6 | 6-Teams to natywna orkiestracja; workflow gdy >5 niezależnych slice'ów. |
| 8 | Five-Axis na skalę: agent per oś + adwersaryjna weryfikacja znalezisk. |

## 6. Limity (Chesterton dla racjonalizacji) — z DOC §9

Max **16 agentów równolegle**, max **1000 agentów/run**, brak interaktywności w locie, brak bezpośredniego IO skryptu wiodącego (delegacja do subagentów), **wyższy token usage** (liczy się do ratelimitów — sprawdź `/model` przed dużym runem).

## 7. Reguła ładowania (Progressive Disclosure)

Ładuj gdy: Phase 0 wykryła **size M/L** lub trigger `workflow`/`ultracode`; Phase 1 deep analysis; Phase 8 multi-axis review na skalę; ustawiasz reasoning budget. Dla **S/M synchronicznych** — pomiń.

## Sources

- [DOC/dynamic_workflows-cc.md](../../../DOC/dynamic_workflows-cc.md) — lokalny kanon (research-report, §1–§14).
- https://code.claude.com/docs/en/workflows — Orchestrate subagents at scale.
- https://code.claude.com/docs/en/model-config — effort levels (low/medium/high/xhigh/max).
- Uwaga: anchory typu `#let-claude-decide-with-ultracode` pochodzą z researchu i nie były weryfikowane zewnętrznie w tej sesji.
