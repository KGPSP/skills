// Sample test from qa-architect blueprint.
// Warstwa: integration DB (Testcontainers + real PostgreSQL)
// Wzorzec: references/stack-profiles/nextjs-react.md §9, layer-strategy.md §3 (Modyfikacja 2)
//
// Demonstrates:
//   - Real PostgreSQL via @testcontainers/postgresql (NOT pg-mem)
//   - Per-suite lifecycle: beforeAll start, afterAll stop
//   - Per-test isolation: beforeEach BEGIN, afterEach ROLLBACK
//   - Same-client transaction (node-postgres requirement)

import { beforeAll, afterAll, beforeEach, afterEach, describe, test, expect } from 'vitest'
import { PostgreSqlContainer, type StartedPostgreSqlContainer } from '@testcontainers/postgresql'
import { Pool, type PoolClient } from 'pg'

// --- Schema migration (would normally live in db/migrations/) ---
async function up(client: PoolClient): Promise<void> {
  await client.query(`
    CREATE TABLE IF NOT EXISTS app_user (
      id BIGSERIAL PRIMARY KEY,
      email TEXT NOT NULL UNIQUE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT now()
    )
  `)
}

// --- Repository under test (would normally live in src/server/db/users.repo.ts) ---
async function insertUser(client: PoolClient, email: string) {
  const result = await client.query({
    name: 'insert-user',
    text: 'INSERT INTO app_user(email) VALUES ($1) RETURNING id, email',
    values: [email]
  })
  return result.rows[0] as { id: string; email: string }
}

// --- Test lifecycle ---
let container: StartedPostgreSqlContainer
let pool: Pool
let client: PoolClient

beforeAll(async () => {
  container = await new PostgreSqlContainer('postgres:16-alpine').start()
  pool = new Pool({ connectionString: container.getConnectionUri() })
  const bootstrap = await pool.connect()
  try {
    await up(bootstrap)
  } finally {
    bootstrap.release()
  }
}, 60_000)

afterAll(async () => {
  await pool.end()
  await container.stop()
})

beforeEach(async () => {
  client = await pool.connect()
  await client.query('BEGIN')
})

afterEach(async () => {
  await client.query('ROLLBACK')
  client.release()
})

describe('users.repo (integration DB)', () => {
  test('inserts a user (happy path)', async () => {
    const row = await insertUser(client, 'anna@example.com')
    expect(row.email).toBe('anna@example.com')
    expect(row.id).toMatch(/^\d+$/)
  })

  test('rejects duplicate email (edge case — UNIQUE constraint)', async () => {
    await insertUser(client, 'duplicate@example.com')
    await expect(insertUser(client, 'duplicate@example.com')).rejects.toThrow(/unique|duplicate/i)
  })
})
