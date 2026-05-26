// BAD fixture — uses vi.mock on 'pg' which is forbidden anti-pattern (paper §4.2, §8.5).
// verify-postgres-strategy.sh MUST flag this file as a violation.

import { vi, test, expect } from 'vitest'

vi.mock('pg', () => ({
  Pool: vi.fn().mockImplementation(() => ({
    connect: vi.fn().mockResolvedValue({ query: vi.fn(), release: vi.fn() })
  }))
}))

test('does not use real postgres (anti-pattern)', () => {
  expect(true).toBe(true)
})
