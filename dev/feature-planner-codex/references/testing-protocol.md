# Testing Protocol

Use this reference when a feature needs more than a trivial smoke check.

## Test Selection

Choose the smallest verification set that proves the change:

- Pure logic: unit tests for touched functions.
- API route: request-level integration test plus auth/validation cases.
- Database change: migration/schema check plus round-trip read/write test.
- Frontend behavior: browser test or Playwright manual flow with screenshot when layout/interaction matters.
- GIS/data pipeline: domain validation script plus count/CRS/topology checks.

## Recommended Order

1. Run focused tests for touched code.
2. Run typecheck/build.
3. Run integration tests for changed boundaries.
4. Run manual/browser validation for user-facing UI.
5. Run full suite only when risk or project conventions justify it.

## Reporting

Report exactly:

- command,
- result,
- relevant warning,
- reason if skipped.

Use concise wording:

```text
Verification:
- `npm test -- topology.test.ts`: passed
- `npm run build`: passed, Vite bundle-size warning only
- Browser check: selected feature, dragged node, no map pan regression
```

## Failure Handling

If a test fails:

- read the failure,
- identify whether it is caused by your change,
- fix and rerun the narrow test,
- do not hide unrelated existing failures; mark them as pre-existing only with evidence.
