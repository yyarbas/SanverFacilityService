import { test, expect } from '@playwright/test';

test.describe('Startseite', () => {

  test('Seite lädt und Titel ist korrekt', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveTitle(/Sanver Facility Service/i);
  });

  test('Logo ist sichtbar', async ({ page }) => {
    await page.goto('/');
    const logo = page.locator('nav img[alt*="Sanver"]');
    await expect(logo).toBeVisible();
  });

  test('Navigation enthält alle Links', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('nav a[href="#ueber-uns"]')).toBeVisible();
    await expect(page.locator('nav a[href="#leistungen"]')).toBeVisible();
    await expect(page.locator('nav a[href="#vorteile"]')).toBeVisible();
    await expect(page.locator('nav a[href="#kontakt"]')).toBeVisible();
  });

  test('CTA-Button "Termin buchen" ist sichtbar', async ({ page }) => {
    await page.goto('/');
    const cta = page.locator('a:has-text("Termin buchen")').first();
    await expect(cta).toBeVisible();
  });

  test('Alle Sektionen sind vorhanden', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('#ueber-uns, [id="ueber-uns"]')).toBeVisible();
    await expect(page.locator('#leistungen, [id="leistungen"]')).toBeVisible();
  });

  test('Keine kaputten Bilder', async ({ page }) => {
    await page.goto('/');
    const images = page.locator('img');
    const count = await images.count();

    for (let i = 0; i < count; i++) {
      const img = images.nth(i);
      const naturalWidth = await img.evaluate((el: HTMLImageElement) => el.naturalWidth);
      const src = await img.getAttribute('src');
      expect(naturalWidth, `Bild geladen: ${src}`).toBeGreaterThan(0);
    }
  });

  test('Mobile: Hamburger-Menü funktioniert', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 812 });
    await page.goto('/');

    const toggle = page.locator('#navToggle, button[aria-label*="Menü"]');
    await expect(toggle).toBeVisible();

    await toggle.click();
    const navLinks = page.locator('#navLinks, .nav-links');
    await expect(navLinks).toBeVisible();
  });

});
