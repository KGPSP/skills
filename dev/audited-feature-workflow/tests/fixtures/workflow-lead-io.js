// workflow-lead-io.js — BAD fixture (lead-IO: process.env access -> DOC §9).
// source: DOC/dynamic_workflows-cc.md §9
// DOC-CONSTRAINTS: gates-outside

export const meta = { name: 'io', description: 'x', phases: [] }

phase('X')
const home = process.env.HOME
const out = await parallel([() => agent(`read ${home}`, { label: 'r' })])
return out
