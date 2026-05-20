---
title: Prompty systemowe dla 3 rdzennych ról zespołu Agent Teams
purpose: gotowe definicje sub-agentów Claude Code; przenieś do `.claude/agents/` w katalogu projektu (faza 2 SKILL.md)
source: references/role-mapping.md §2 (Prompty systemowe — szablony)
---

# Prompty systemowe (Planner, Generator, Evaluator)

> **WAŻNE:** Aktualne, gotowe do skopiowania definicje sub-agentów Claude Code znajdują się w `agents/` skilla (NIE w tym pliku — ten plik dokumentuje strukturę):
>
> - `agents/planner.md` — Planner (frontmatter: name, description, tools, model)
> - `agents/generator.md` — Generator
> - `agents/evaluator.md` — Evaluator
>
> Procedura kopiowania w fazie 2 SKILL.md:
>
> ```bash
> mkdir -p .claude/agents
> cp {skill-dir}/agents/planner.md   .claude/agents/
> cp {skill-dir}/agents/generator.md .claude/agents/
> cp {skill-dir}/agents/evaluator.md .claude/agents/
> ```
>
> Po skopiowaniu Claude Code automatycznie wykrywa sub-agenty. Parent agent wywołuje przez Task tool:
>
> ```
> Task(
>   description: "Spawn Planner",
>   subagent_type: "planner",
>   prompt: "<oryginalny prompt + assets/plan-template.md>"
> )
> ```

---

## Struktura jednego sub-agenta (referencja)

Każdy plik w `agents/` ma format:

```markdown
---
name: <kebab-case-name>          # musi pasować do subagent_type
description: <kiedy używać>      # router decyduje na podstawie tego
tools: Read, Write, Edit, Bash   # CSV — allowed-tools per rola
model: claude-opus-4-7           # opcjonalnie
---

# Rola: <Nazwa>

<system prompt — jak ma się zachowywać>

## Workflow
1. ...
2. ...

## ZAKAZY
- ...

## REGUŁY
- ...

## Exit criterion
- ...
```

---

## Walidacja izolacji ról

Po skopiowaniu do `.claude/agents/` uruchom:

```bash
bash scripts/verify-role-isolation.sh
```

Sprawdza:

- `agents/generator.md` **NIE** zawiera `mcp__playwright`, `mcp__chrome-devtools`, `mcp__computer-use` w `tools`.
- `agents/evaluator.md` **NIE** zawiera `Edit` w `tools` (tylko Read/Bash/Write z ograniczeniami).
- Każdy plik ma frontmatter z `name`, `description`, `tools`.

Brak exit 0 → popraw definicje sub-agentów PRZED pierwszym wywołaniem przez Task tool.

---

## Rozszerzenia (faza 2 §5)

Dla projektów >5 sprintów dodaj sub-agenty w `agents/`:

- `frontend-builder.md` — UI layer, komponenty, stylowanie (dziedziczy ZAKAZY i REGUŁY z `generator.md`, ograniczone do `src/components/`).
- `backend-builder.md` — API, logika serwerowa.
- `integrator.md` — spaja FE+BE+DB, deployment.
- Per każdy builder — dedykowany evaluator: `frontend-qa.md`, `backend-qa.md`, `e2e-qa.md`.

Wzorce: skopiuj `agents/generator.md` lub `agents/evaluator.md` i zmień:

- `name` na nowy.
- `description` — opisz specjalizację.
- `tools` — zawęź do potrzebnych dla tej roli.
- Sekcja "Workflow" — dodaj specjalizację (np. "tylko pliki w `src/api/`").

Pełna lista ról i skalowanie: `references/role-mapping.md §3`.
