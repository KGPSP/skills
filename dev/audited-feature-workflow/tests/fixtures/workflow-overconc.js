// workflow-overconc.js — BAD fixture (concurrency > 16 via slice(0,32) -> DOC §9).
// source: DOC/dynamic_workflows-cc.md §9
// DOC-CONSTRAINTS: gates-outside

export const meta = { name: 'oc', description: 'x', phases: [] }

const items = args || []
phase('X')
const out = await parallel(items.slice(0, 32).map((i) => () => agent(`${i}`, { label: 'r' })))
return out
