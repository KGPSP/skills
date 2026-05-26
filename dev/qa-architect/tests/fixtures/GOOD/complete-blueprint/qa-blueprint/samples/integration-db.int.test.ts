// good fixture integration-db — uses Testcontainers, no mocks
import { test, expect, beforeAll, afterAll } from 'vitest'
import { PostgreSqlContainer } from '@testcontainers/postgresql'
let container: any
beforeAll(async () => { container = await new PostgreSqlContainer().start() }, 60_000)
afterAll(async () => { await container?.stop() })
test('ok', () => expect(true).toBe(true))
