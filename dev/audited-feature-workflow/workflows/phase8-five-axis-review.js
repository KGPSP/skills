// phase8-five-axis-review.js — Phase 8 Dynamic Workflow (exemplar template, NOT runtime-verified).
// source: DOC/dynamic_workflows-cc.md §4/§5.3/§9; DOC/Messages_API_w_Opus_4.8.md §9/§10
// DOC-CONSTRAINTS: no-mid-run-input; gates-outside(APPROVAL#1-#5,Gate#1.5); concurrency<=16; total<=1000; excl(/goal,--fragile,6-Teams-Phase8); model=claude-opus-4-8(session-inherited)
//
// Five-Axis review at scale: one agent per axis, then adversarial verify per finding.
// Bypass-safe: emits review findings only; APPROVAL #5 stays in the main loop (NOT here).
// Mutually exclusive with 6-Teams Phase 8 (choose by independent-axis count, else double-run).
// Adversarial verify = reinforcement, not gate-replacement (dynamic-workflows-standard.md §4).

export const meta = {
  name: 'aftw-phase8-five-axis-review',
  description: 'Phase 8 Five-Axis review: agent per axis, adversarial verify per finding',
  phases: [
    { title: 'Review' },
    { title: 'Verify' },
  ],
}

const AXIS_SCHEMA = {
  type: 'object',
  required: ['axis', 'findings'],
  properties: {
    axis: { type: 'string' },
    findings: { type: 'array', items: { type: 'string' } },
  },
}

const AXES = ['correctness', 'readability', 'architecture', 'security', 'performance']

const reviewed = await pipeline(
  AXES,
  (axis) => agent(`Review the diff on the ${axis} axis. List findings with severity (Critical/Optional/Nit/FYI).`,
    { label: `axis:${axis}`, phase: 'Review', schema: AXIS_SCHEMA }),
  (review) => parallel((review.findings).map((f) => () =>
    agent(`Adversarially verify this ${review.axis} finding (refute by default): ${f}`,
      { label: `verify:${review.axis}`, phase: 'Verify' })))
)

log(`Five-Axis done: ${reviewed.length} axes reviewed`)

return reviewed
