# PHASE: evaluate

Workspace: `{{WORKSPACE}}`
Run id: `{{RUN_ID}}`
Sprint: `{{SPRINT}}`
Contract: `{{STATE_DIR}}/contracts/sprint-{{SPRINT}}.json`
Evidence directory: `{{STATE_DIR}}/evidence`

Evaluate the implementation against the contract. Run real checks in the target
workspace. Store evidence files under `state/evidence/` and update the contract
with binary pass/fail observations and evidence paths.

Do not edit product code. Feedback must describe what failed, not how to fix it.
