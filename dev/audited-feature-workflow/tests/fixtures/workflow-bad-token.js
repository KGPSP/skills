// workflow-bad-token.js — BAD fixture (typo "paralel(" -> closed-world token lint).
// source: DOC/dynamic_workflows-cc.md §5.3
// DOC-CONSTRAINTS: gates-outside

export const meta = { name: 'bad', description: 'x', phases: [] }

phase('X')
const out = await paralel([() => agent('x', { label: 'r' })])
return out
