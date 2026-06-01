// workflow-phase1-good.js — GOOD fixture for check-workflow-scripts.sh (parses + lints clean).
// source: DOC/dynamic_workflows-cc.md §5.3
// DOC-CONSTRAINTS: no-mid-run-input; gates-outside; concurrency<=16

export const meta = { name: 'good', description: 'good', phases: [{ title: 'X' }] }

phase('X')
const out = (await parallel([() => agent('read one thing', { label: 'r' })])).filter(Boolean)
log(`${out.length} done`)
return out
