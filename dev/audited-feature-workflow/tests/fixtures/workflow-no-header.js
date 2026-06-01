// workflow-no-header.js — BAD fixture (missing // DOC-CONSTRAINTS: header).
// source: DOC/dynamic_workflows-cc.md §5.3

export const meta = { name: 'nohdr', description: 'x', phases: [] }

phase('X')
const out = await parallel([() => agent('x', { label: 'r' })])
return out
