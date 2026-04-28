# Code Review Protocol

Use this reference for review-style responses and final implementation review.

## Review Stance

Prioritize:

1. correctness bugs,
2. data loss or security risks,
3. behavioral regressions,
4. missing tests for changed behavior,
5. maintainability issues with real future cost.

Avoid style-only findings unless they hide a real defect.

## Severity

- `P0`: data loss, security incident, production outage.
- `P1`: likely user-facing breakage or serious correctness bug.
- `P2`: plausible bug, missing important test, maintainability risk.
- `P3`: minor issue or follow-up improvement.

## Output Shape

Findings first:

```markdown
Findings
- [P1] Title - file:line
  Explanation and concrete failure mode.

Open Questions
- ...

Summary
- ...

Tests
- ...
```

When the environment supports inline comments, emit one directive per finding:

```text
::code-comment{title="[P1] Short title" body="One-paragraph finding with failure mode and fix direction." file="/absolute/path/file.ts" start=42 end=44 priority=1 confidence=0.8}
```

If no findings:

```text
No blocking findings. Residual risk: [test gap or unverified area].
```

## Review After Implementation

Before final response:

- inspect your diff,
- confirm no unrelated files were changed,
- verify tests/build,
- check for stale debug logs, temporary artifacts, active locks, or running sessions that should not remain.
