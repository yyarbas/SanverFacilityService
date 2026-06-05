import { test, expect } from '@playwright/test';

test.describe('Unterseiten', () => {

  test('Impressum lädt', async ({ page }) => {
    await page.goto('/impressum');
    await expect(page).toHaveTitle(/Impressum/i);
    await expect(page.locator('h1')).toBeVisible();
  });

  test('Datenschutz lädt', async ({ page }) => {
    await page.goto('/datenschutz');
    await expect(page).toHaveTitle(/Datenschutz/i);
    await expect(page.locator('h1')).toBeVisible();
  });

  test('AGB lädt', async ({ page }) => {
    await page.goto('/agb');
    await expect(page).toHaveTitle(/AGB/i);
    await expect(page.locator('h1')).toBeVisible();
  });

  test('Footer-Links zu Impressum und Datenschutz funktionieren', async ({ page }) => {
    await page.goto('/');

    await page.locator('footer a[href*="impressum"]').click();
    await expect(page).toHaveURL(/impressum/);

    await page.goBack();

    await page.locator('footer a[href*="datenschutz"]').click();
    await expect(page).toHaveURL(/datenschutz/);
  });

});
