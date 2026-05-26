# PHASE: contract

Workspace: `{{WORKSPACE}}`
Run id: `{{RUN_ID}}`
Sprint: `{{SPRINT}}`
Plan: `{{STATE_DIR}}/plan.md`
Contract: `{{STATE_DIR}}/contracts/sprint-{{SPRINT}}.json`

Converge on a binary sprint contract. The contract must contain criteria with
stable ids, explicit checks, paths in scope, and an empty evidence ledger.

Generator proposes implementation-facing criteria. Evaluator tightens them into
observable pass/fail checks. Do not implement code during this phase.
