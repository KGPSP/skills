// workflow-syntax-bad.js — BAD fixture (syntax error: unbalanced brackets).
// source: DOC/dynamic_workflows-cc.md §5.3
// DOC-CONSTRAINTS: gates-outside

phase('X')
const out = await parallel([() => agent('x', { label: 'r' })
log(`${out}`)
return out
