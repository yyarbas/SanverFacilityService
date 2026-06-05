import { test, expect } from '@playwright/test';

test.describe('Cal.eu Buchungs-Widget', () => {

  test.beforeEach(async ({ page }) => {
    await page.goto('/#termin');
    // Kurz warten bis iframe geladen
    await page.waitForTimeout(1000);
  });

  test('Buchungs-Sektion ist sichtbar', async ({ page }) => {
    const section = page.locator('#termin');
    await expect(section).toBeVisible();
    await expect(section.locator('h2')).toContainText('Erstgespräch');
  });

  test('Cal.eu iframe ist eingebettet', async ({ page }) => {
    const iframe = page.locator('#cal-embed');
    await expect(iframe).toBeVisible();

    const src = await iframe.getAttribute('src');
    expect(src).toContain('cal.eu');
    expect(src).toContain('sanver-facilityservice');
  });

  test('Standardmäßig ist 30min aktiv', async ({ page }) => {
    const iframe = page.locator('#cal-embed');
    const src = await iframe.getAttribute('src');
    expect(src).toContain('30min');

    const activeBtn = page.locator('.cal-toggle-btn.active');
    await expect(activeBtn).toContainText('30 Min');
  });

  test('Toggle wechselt auf 15min', async ({ page }) => {
    const btn15 = page.locator('.cal-toggle-btn', { hasText: '15 Min' });
    await btn15.click();

    // iframe src soll auf 15min wechseln
    const iframe = page.locator('#cal-embed');
    await expect(async () => {
      const src = await iframe.getAttribute('src');
      expect(src).toContain('15min');
    }).toPass({ timeout: 3000 });

    // 15min-Button soll aktiv sein
    await expect(btn15).toHaveClass(/active/);
  });

  test('Toggle zurück auf 30min', async ({ page }) => {
    // Erst auf 15min
    await page.locator('.cal-toggle-btn', { hasText: '15 Min' }).click();

    // Dann zurück auf 30min
    const btn30 = page.locator('.cal-toggle-btn', { hasText: '30 Min' });
    await btn30.click();

    const iframe = page.locator('#cal-embed');
    await expect(async () => {
      const src = await iframe.getAttribute('src');
      expect(src).toContain('30min');
    }).toPass({ timeout: 3000 });

    await expect(btn30).toHaveClass(/active/);
  });

  test('iframe URL enthält Light-Theme und Embed-Parameter', async ({ page }) => {
    const iframe = page.locator('#cal-embed');
    const src = await iframe.getAttribute('src');
    expect(src).toContain('embed=true');
    expect(src).toContain('theme=light');
  });

  test('CTA-Link scrollt zur Buchungs-Sektion', async ({ page }) => {
    await page.goto('/');

    // Klick auf "Termin buchen" im Hero
    await page.locator('a[href="#termin"]').first().click();

    // Section sollte im Viewport sein
    const section = page.locator('#termin');
    await expect(section).toBeInViewport({ timeout: 2000 });
  });

});
