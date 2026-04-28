/**
 * Auramika Daily — App Store Screenshot Exporter
 * Generates ready-to-submit PNGs for App Store Connect.
 * Usage: node export.js
 */

const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

const OUT = path.join(__dirname, 'out');
if (!fs.existsSync(OUT)) fs.mkdirSync(OUT);

const TARGETS = [
  { html: 'iphone.html', w: 1242, h: 2688, prefix: 'iphone' },
  { html: 'ipad.html',   w: 2048, h: 2732, prefix: 'ipad'   },
];

(async () => {
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  for (const { html, w, h, prefix } of TARGETS) {
    const url = 'file://' + path.join(__dirname, html);
    console.log(`\nLoading ${html} (${w}×${h})`);

    const page = await browser.newPage();
    await page.setViewport({ width: w + 200, height: h + 300, deviceScaleFactor: 1 });
    await page.goto(url, { waitUntil: 'networkidle0', timeout: 30000 });

    // Wait for fonts
    await page.waitForFunction(() => document.fonts.ready);
    await new Promise(r => setTimeout(r, 1000)); // extra settle time for images

    const slides = await page.$$('.slide');
    console.log(`  Found ${slides.length} slides`);

    for (let i = 0; i < slides.length; i++) {
      const out = path.join(OUT, `${prefix}_${String(i + 1).padStart(2, '0')}.png`);
      await slides[i].screenshot({ path: out });
      console.log(`  ✓ ${path.basename(out)}`);
    }

    await page.close();
  }

  await browser.close();
  console.log(`\nAll done → ${OUT}`);
})().catch(e => { console.error(e); process.exit(1); });
