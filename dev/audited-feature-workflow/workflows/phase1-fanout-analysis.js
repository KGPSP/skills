// phase1-fanout-analysis.js — Phase 1 Dynamic Workflow (exemplar template, NOT runtime-verified).
// source: DOC/dynamic_workflows-cc.md §1/§5.3/§9; DOC/Messages_API_w_Opus_4.8.md §9/§10
// DOC-CONSTRAINTS: no-mid-run-input; gates-outside(APPROVAL#1-#5,Gate#1.5); concurrency<=16; total<=1000; excl(/goal,--fragile); model=claude-opus-4-8(session-inherited)
//
// Phase 1 Deep Analysis fan-out: one reader per subsystem, then a single synthesis.
// Bypass-safe: reads only, mutates nothing, crosses no approval gate. The synthesized
// report returns to the main loop, where Phase-1 gates and APPROVAL #1 run OUTSIDE this run.
// Pass the subsystem list as `args` (e.g. ["src/api","src/db","src/ui"]).

export const meta = {
  name: 'aftw-phase1-fanout-analysis',
  description: 'Phase 1 deep analysis: fan-out one reader per subsystem, then synthesize',
  phases: [
    { title: 'Read' },
    { title: 'Synthesize' },
  ],
}

const MAP_SCHEMA = {
  type: 'object',
  required: ['subsystem', 'findings'],
  properties: {
    subsystem: { type: 'string' },
    findings: { type: 'array', items: { type: 'string' } },
  },
}

const subsystems = args || []

phase('Read')
const maps = (await parallel(subsystems.map((s) => () =>
  agent(`Read subsystem ${s}. Map architecture, public exports (Hyrum), deletion candidates (Chesterton). Findings only.`,
    { label: `read:${s}`, phase: 'Read', schema: MAP_SCHEMA })
))).filter(Boolean)

log(`Read done: ${maps.length} subsystem maps`)

phase('Synthesize')
const report = await agent(
  `Synthesize one Phase 1 analysis report from these subsystem maps: ${JSON.stringify(maps)}. ` +
  `Output PRIMARY TEMPLATE, architecture walk, analog feature, Hyrum impact, Chesterton scan.`,
  { label: 'synthesize', phase: 'Synthesize' }
)

return report
