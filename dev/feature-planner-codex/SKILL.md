---
name: feature-planner-v2-codex
version: v1.0.0
description: Structured Codex-native feature planning and execution workflow. Use when the user asks to plan, analyze, implement, review, or document a software feature end-to-end with codebase analysis, acceptance criteria, tests, code review, and ADR-style decision records.
---

# Feature Planner v2 Codex

Use this skill to turn a feature request into a disciplined Codex workflow:
analyze -> hypothesize -> plan -> implement when requested -> test -> review -> document.

This skill is Codex-native. Do not use Claude Code concepts such as slash commands, `.claude/settings.json`, `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`, `WebSearch`/`WebFetch`, `Task`, `superpowers`, `delegate-*`, or automatic agent teams.

## Codex Tool Policy

- Prefer `rg`, `rg --files`, `sed`, `nl`, `ls`, `find`, `git diff`, and targeted file reads.
- Use `multi_tool_use.parallel` for independent reads/searches.
- Use `update_plan` for visible progress on multi-step work.
- Use `request_user_input` only when it is available and a blocking choice exists. In Default mode, ask one concise plain-text question only if needed.
- Use `web.run` when the information is recent, external, legal/medical/financial, source-specific, or explicitly requested by the user.
- Use the `context7` skill when implementing or debugging external libraries and current API behavior matters.
- Use `tool_search` for deferred tools such as browser/app/MCP capabilities.
- Use Browser Use or Playwright for local UI inspection, browser screenshots, and localhost verification.
- Do not spawn subagents unless the user explicitly asks for subagents, delegation, or parallel agent work. If allowed, use Codex `spawn_agent` with `explorer` or `worker` roles and disjoint scopes.
- Do not commit unless the user explicitly asks for commits. If commits are requested, use explicit non-interactive git commands and never revert unrelated user changes.

## Phase 0: Prepare

Create plan directories only when an artifact is useful for the task:

```bash
mkdir -p docs/plany docs/plany/_analysis docs/code-reviews docs/adr
PLAN_NUM_RAW=$(
  find docs/plany -maxdepth 1 -type f -name '[0-9][0-9][0-9]-*.md' 2>/dev/null \
    | sed -E 's#.*/0*([0-9]+)-.*#\1#' \
    | sort -n | tail -1
)
PLAN_NUM_RAW=$(( ${PLAN_NUM_RAW:-0} + 1 ))
PLAN_NUM=$(printf "%03d" "$PLAN_NUM_RAW")
echo "$PLAN_NUM"
```

Use the actual number everywhere. Do not output the literal string `PLAN_NUM` in generated artifact paths.

## Phase 1: Deep Analysis

Read `references/analysis-protocol.md` when the change is medium/large, touches shared behavior, or the codebase is unfamiliar.

Minimum analysis before proposing changes:

1. Detect stack and scripts from package/config files.
2. Walk entry -> routing -> service/domain -> persistence.
3. Find the closest existing analog and read it end to end.
4. Snapshot affected data models and migrations.
5. Reverse-search likely dependencies and importers.
6. Inspect tests as executable specification.
7. Record external research used, or `none`.

Output an Analysis Report when the user asked for planning or when the implementation risk is non-trivial:

```markdown
# Analysis Report - plan #NNN

## Stack
[one-line stack]

## Architecture
Entry: ... -> Routing: ... -> Service: ... -> DB: ...

## Primary Analog
- Feature:
- Key files:
- Pattern:

## Affected Model
- Tables/types:
- Relations:

## Dependency Radius
- Files likely affected:
- Out of scope:

## Tests As Spec
- Existing tests:
- Missing test surface:

## Research Used
- none | context7: ... | web: ... | browser: ...
```

## Phase 2: Hypotheses

Before implementation, state 2-4 implementation hypotheses when the task is ambiguous:

- likely integration point,
- expected data shape,
- risk or unknown,
- verification path.

Keep this short. Drop hypotheses that the code already disproves.

## Phase 3: Implementation Plan

Produce a concrete plan only when the user asked for a plan, the task is large, or you need to coordinate risk. Otherwise implement directly after enough analysis.

Plan format:

```markdown
# Plan NNN - [feature slug]

## Summary
[what will change and why]

## Scope
- In:
- Out:

## Files
- [path] - [reason]

## Tasks
1. [task with owner/scope]
2. [task with dependency if any]

## Acceptance Criteria
- [binary condition]

## Test Plan
- [commands/manual checks]

## Rollback
- [how to back out]
```

For task parallelism, use plain labels such as `parallel group: backend`, but only delegate if the user explicitly allowed subagents.

## Phase 4: Implement

When the user asks to implement:

- Follow the repository's existing patterns before adding new abstractions.
- Keep edits scoped to the planned files and behavior.
- Use `apply_patch` for manual edits.
- Do not rewrite unrelated code or generated artifacts.
- Maintain a visible checklist with `update_plan` for multi-step implementation.
- Update plan item status as work completes.
- If user changes appear during work, preserve them and adapt.

If blocked by a missing decision, ask one focused question. Prefer a conservative local assumption when the answer is discoverable from code.

## Phase 5: Test

Read `references/testing-protocol.md` for a fuller checklist when the change touches shared code, auth, data persistence, GIS, or UI workflows.

Always run the narrowest meaningful verification first, then broader checks if risk warrants it:

- unit tests for touched logic,
- integration/API tests for changed routes,
- build/typecheck for TypeScript,
- browser verification for UI changes,
- domain validation scripts for data/GIS changes.

Report commands run and whether they passed. If a command could not run, state why.

## Phase 6: Acceptance Criteria

Read `references/ac-protocol.md` when the user asks for acceptance criteria or when the work needs a formal review gate.

Write AC as binary checks:

- `AC-F` functional behavior,
- `AC-T` technical/code quality,
- `AC-N` non-functional requirements such as auth, accessibility, performance, compliance.

Each AC must be specific, testable, traceable, and independent.

## Phase 7: Code Review

Read `references/code-review-protocol.md` when the user asks for code review or before closing a risky implementation.

Use Codex review conventions:

- Findings first, ordered by severity.
- Include precise file/line references.
- Use `::code-comment{...}` directives for inline review findings when useful.
- If no issues are found, say so clearly and list residual risks or test gaps.
- Do not bury serious findings under a summary.

## Phase 8: ADR / Decision Record

Read `references/adr-template.md` when the plan makes an architectural or operational decision worth preserving.

Save ADRs under `docs/adr/NNN-[slug].md` when the repository uses docs artifacts or when the user asks for documentation.

## Done Criteria

Finish with:

- what changed,
- where the important files are,
- what verification passed,
- known limitations or follow-up risks,
- how to run or inspect the result when applicable.
