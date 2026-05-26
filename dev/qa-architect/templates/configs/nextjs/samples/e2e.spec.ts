// Sample test from qa-architect blueprint.
// Warstwa: E2E (Playwright)
// Wzorzec: references/stack-profiles/nextjs-react.md §9
//
// Demonstrates:
//   - Semantic locators (getByRole > getByLabel > getByTestId escape hatch)
//   - No fixed waitForTimeout — Playwright auto-waits
//   - @smoke tag for PR workflow filter (`--grep "@smoke|@golden"`)
//   - 1 golden path + 1 edge case

import { test, expect } from '@playwright/test'

test.describe('Login flow', () => {
  test('@smoke logs in with valid credentials (golden path)', async ({ page }) => {
    await page.goto('/login')

    await page.getByLabel('Email').fill('anna@example.com')
    await page.getByLabel('Hasło').fill('tajnehaslo')
    await page.getByRole('button', { name: 'Zaloguj' }).click()

    await expect(page).toHaveURL(/\/dashboard/)
    await expect(page.getByRole('heading', { name: /witaj.*anna/i })).toBeVisible()
  })

  test('shows error on invalid credentials (edge case)', async ({ page }) => {
    await page.goto('/login')

    await page.getByLabel('Email').fill('wrong@example.com')
    await page.getByLabel('Hasło').fill('badpassword')
    await page.getByRole('button', { name: 'Zaloguj' }).click()

    await expect(page.getByRole('alert')).toContainText(/nieprawidłowe|invalid/i)
    await expect(page).toHaveURL(/\/login/)   // still on login page
  })
})
