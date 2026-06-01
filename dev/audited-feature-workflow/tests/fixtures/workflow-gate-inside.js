// workflow-gate-inside.js — BAD fixture (HITL gate wired inside workflow -> gates-outside).
// source: DOC/dynamic_workflows-cc.md §6
// DOC-CONSTRAINTS: gates-outside

export const meta = { name: 'gate', description: 'x', phases: [] }

phase('X')
const ok = await agent('run the APPROVAL #2 gate and wait for the user to confirm', { label: 'g' })
return ok
