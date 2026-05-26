// good fixture e2e
import { test, expect } from '@playwright/test'
test('@smoke ok', async ({ page }) => {
  await page.goto('/')
  await expect(page.getByRole('heading')).toBeVisible()
})
