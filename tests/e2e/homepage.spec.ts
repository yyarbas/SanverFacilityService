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
    // Links im DOM vorhanden (können auf Mobile versteckt sein)
    await expect(page.locator('nav a[href="#ueber-uns"]')).toBeAttached();
    await expect(page.locator('nav a[href="#leistungen"]')).toBeAttached();
    await expect(page.locator('nav a[href="#vorteile"]')).toBeAttached();
    await expect(page.locator('nav a[href="#kontakt"]')).toBeAttached();
  });

  test('CTA-Button "Termin buchen" ist vorhanden', async ({ page }) => {
    await page.goto('/');
    const cta = page.locator('a:has-text("Termin buchen")').first();
    await expect(cta).toBeAttached();
  });

  test('Alle Sektionen sind vorhanden', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('#ueber-uns')).toBeAttached();
    await expect(page.locator('#leistungen')).toBeAttached();
  });

  test('Keine kaputten Bilder', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    const images = page.locator('img');
    const count = await images.count();

    for (let i = 0; i < count; i++) {
      const img = images.nth(i);
      const naturalWidth = await img.evaluate((el: HTMLImageElement) => el.naturalWidth);
      const src = await img.getAttribute('src');
      expect(naturalWidth, `Bild geladen: ${src}`).toBeGreaterThan(0);
    }
  });

  test('Desktop: Navigation Links sichtbar', async ({ page }) => {
    await page.setViewportSize({ width: 1280, height: 800 });
    await page.goto('/');
    await expect(page.locator('nav a[href="#leistungen"]')).toBeVisible();
  });

  test('Mobile: Hamburger-Menü öffnet Navigation', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 812 });
    await page.goto('/');

    const toggle = page.locator('#navToggle, button[aria-label*="Menü"]');
    await expect(toggle).toBeVisible();
    await toggle.click();

    const navLinks = page.locator('#navLinks, .nav-links');
    await expect(navLinks).toBeVisible();
  });

});
