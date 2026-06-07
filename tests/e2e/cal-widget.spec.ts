import { test, expect } from '@playwright/test';

// Das Astro Booking-Widget nutzt ein script-basiertes Cal.com Embed (kein iframe src).
// Getestet wird: Sektion, Container, Lade-Zustand, Scroll-Verhalten.

test.describe('Cal.eu Buchungs-Widget', () => {

  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
  });

  test('Buchungs-Sektion ist vorhanden', async ({ page }) => {
    const section = page.locator('#termin');
    await expect(section).toBeAttached();
    await expect(section.locator('h2')).toContainText('Erstgespräch');
  });

  test('Cal-Embed-Container ist vorhanden', async ({ page }) => {
    const embed = page.locator('#cal-embed');
    await expect(embed).toBeAttached();
  });

  test('Buchungs-Sektion hat Mindesthöhe (Widget hat Platz)', async ({ page }) => {
    const embed = page.locator('#cal-embed');
    const box = await embed.boundingBox();
    expect(box?.height).toBeGreaterThanOrEqual(500);
  });

  test('CTA-Link scrollt zur Buchungs-Sektion', async ({ page }) => {
    // Hero-CTA nutzen (Nav-CTA ist auf Mobile versteckt)
    const cta = page.locator('main a[href="#termin"], .hero a[href="#termin"]').first();
    await expect(cta).toBeVisible();
    await cta.click();

    const section = page.locator('#termin');
    await expect(section).toBeInViewport({ timeout: 3000 });
  });

  test('Buchungs-Überschrift und Beschreibung sind lesbar', async ({ page }) => {
    const section = page.locator('#termin');
    await expect(section.locator('h2')).toBeVisible();
    await expect(section.locator('p').first()).toBeVisible();
  });

});
