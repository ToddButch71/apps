import { test, expect } from '@playwright/test';

test('App loads and displays table', async ({ page }) => {
  await page.goto('http://localhost:5173');
  await expect(page.locator('table')).toBeVisible();
});

test('Search filters results', async ({ page }) => {
  await page.goto('http://localhost:5173');
  await page.fill('input[type="search"]', 'Bjork');
  const rows = await page.locator('table tbody tr').count();
  expect(rows).toBeGreaterThan(0);
});

test('Stats panel displays correct info', async ({ page }) => {
  await page.goto('http://localhost:5173');
  await expect(page.locator('#totalRecords')).toBeVisible();
  await expect(page.locator('#latestReleaseYear')).toBeVisible();
  await expect(page.locator('#electronicCount')).toBeVisible();
});

test('Responsive layout', async ({ page }) => {
  await page.goto('http://localhost:5173');
  await page.setViewportSize({ width: 375, height: 667 }); // mobile
  await expect(page.locator('table')).toBeVisible();
});