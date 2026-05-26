// Sample test from qa-architect blueprint.
// Warstwa: integration HTTP (Next.js Route Handler)
// Wzorzec: references/stack-profiles/nextjs-react.md §9
//
// Demonstrates:
//   - Next.js Route Handler tested at module level (no full app boot)
//   - vi.mock on the service layer (logic is in services/, handler is thin)
//   - 1 happy path + 1 error path (Beyoncé)

import { vi, describe, test, expect, beforeEach } from 'vitest'

// Mock the service layer — handler should be a thin transport-layer wrapper.
vi.mock('@/server/users.service', () => ({
  listUsers: vi.fn()
}))

import { listUsers } from '@/server/users.service'
import { GET } from '@/app/api/users/route'

describe('GET /api/users', () => {
  beforeEach(() => {
    vi.mocked(listUsers).mockReset()
  })

  test('returns 200 with users list (happy path)', async () => {
    vi.mocked(listUsers).mockResolvedValue([
      { id: 1, email: 'anna@example.com' },
      { id: 2, email: 'jan@example.com' }
    ])

    const response = await GET()

    expect(response.status).toBe(200)
    await expect(response.json()).resolves.toEqual({
      users: [
        { id: 1, email: 'anna@example.com' },
        { id: 2, email: 'jan@example.com' }
      ]
    })
  })

  test('returns 500 when service fails (edge case)', async () => {
    vi.mocked(listUsers).mockRejectedValue(new Error('DB unavailable'))

    const response = await GET()

    expect(response.status).toBe(500)
    await expect(response.json()).resolves.toMatchObject({ error: expect.any(String) })
  })
})
