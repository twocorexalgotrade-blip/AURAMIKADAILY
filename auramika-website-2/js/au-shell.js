/* ============================================================================
   AURAMIKA — Shell Injector
   Stamps nav, grain, cursor, loupe, karat ribbon, aura chip, footer, loader,
   toast into any page that loads this script.
   Pages set <body data-page="products"> etc. for active-link highlighting.
   ============================================================================ */

(function () {
  'use strict';

  function inject() {
    if (document.body.dataset.shell === 'on') return; // already done
    document.body.dataset.shell = 'on';
    document.body.classList.add('auramika-body');

    // Read page id (e.g., "products", "shops", "cart"…)
    const page = document.body.dataset.page || '';

    // ---------- Loader ----------
    if (!document.getElementById('auLoader') && !/[?&]nob=1\b/.test(location.search)) {
      const loader = document.createElement('div');
      loader.className = 'au-loader';
      loader.id = 'auLoader';
      loader.innerHTML = `
        <div class="au-loader__veil"></div>
        <div class="au-loader__inner">
          <div class="au-loader__mark">Auramika</div>
          <div class="au-loader__sub">Crafted with devotion</div>
          <div class="au-loader__bar"></div>
        </div>`;
      document.body.prepend(loader);
      setTimeout(() => {
        loader.style.transition = 'opacity .5s ease';
        loader.style.opacity = '0';
        setTimeout(() => loader.remove(), 500);
      }, 1300);
    }

    // ---------- Grain + cursor ----------
    if (!document.querySelector('.au-grain')) {
      const grain = document.createElement('div'); grain.className = 'au-grain';
      document.body.appendChild(grain);
    }
    if (!document.getElementById('auCursor')) {
      const cur = document.createElement('div'); cur.className = 'au-cursor'; cur.id = 'auCursor'; cur.dataset.label = 'Look';
      const dot = document.createElement('div'); dot.className = 'au-cursor-dot'; dot.id = 'auCursorDot';
      document.body.append(cur, dot);
    }

    // ---------- Loupe (used by .has-loupe) ----------
    if (!document.getElementById('auLoupe')) {
      const loupe = document.createElement('div');
      loupe.className = 'au-loupe'; loupe.id = 'auLoupe'; loupe.dataset.karat = '22k · BIS';
      document.body.appendChild(loupe);
    }

    // ---------- Karat ribbon ----------
    if (!document.getElementById('auKarat')) {
      const k = document.createElement('aside');
      k.className = 'au-karat'; k.id = 'auKarat';
      k.innerHTML = `
        <div class="au-karat__lab">22k Gold · Live</div>
        <div class="au-karat__rate"><span id="krRate">7,184</span><small>₹/g</small></div>
        <div class="au-karat__delta" id="krDelta">▲ 12 (0.17%) today</div>
        <div class="au-karat__cart">Your cart bullion<strong id="krCart">₹ 0</strong></div>`;
      document.body.appendChild(k);
    }

    // ---------- Aura chip ----------
    if (!document.getElementById('auAuraChip')) {
      const chip = document.createElement('button');
      chip.className = 'au-aura-chip'; chip.id = 'auAuraChip'; chip.dataset.cursor = 'Aura';
      chip.innerHTML = `<span class="seal" id="acSeal">A</span><span class="meta"><small id="acTone">Devotion</small><strong id="acName">Your Aura</strong></span>`;
      chip.addEventListener('click', () => location.href = 'index.html#mirror');
      document.body.appendChild(chip);
    }

    // ---------- Glass nav ----------
    if (!document.getElementById('auNav')) {
      const nav = document.createElement('nav');
      nav.className = 'au-nav'; nav.id = 'auNav';
      const links = [
        { href: 'products.html', label: 'Apothecary', id: 'products' },
        { href: 'shops.html',    label: 'Jewellers',  id: 'shops' },
        { href: 'custom-order.html', label: 'Bespoke', id: 'bespoke' },
        { href: 'face_ar.html',  label: 'AR',         id: 'ar' },
      ];
      const linkHtml = links.map(l => `<a href="${l.href}"${page === l.id ? ' class="is-active"' : ''}>${l.label}</a>`).join('');
      nav.innerHTML = `
        <a href="index.html" class="au-nav__brand"><span class="dot"></span>Auramika</a>
        <div class="au-nav__links">${linkHtml}</div>
        <a href="cart.html" class="au-nav__cta">Cart <span id="navCartCount" style="margin-left:6px;opacity:.8">0</span></a>`;
      document.body.appendChild(nav);

      // Sticky scroll state
      const onScroll = () => nav.classList.toggle('is-scrolled', window.scrollY > 60);
      onScroll();
      window.addEventListener('scroll', onScroll, { passive: true });
    }

    // ---------- The Vault Footer ----------
    if (!document.querySelector('link[href$="auramika-footer.css"]')) {
      const link = document.createElement('link');
      link.rel = 'stylesheet';
      link.href = 'styles/pages/auramika-footer.css';
      document.head.appendChild(link);
    }
    if (!document.querySelector('.au-vault')) {
      const v = document.createElement('footer');
      v.className = 'au-vault';
      v.id = 'auVault';

      // Pre-build dial ticks (60) + numbers (12)
      let ticks = '';
      for (let i = 0; i < 60; i++) {
        const long = i % 5 === 0;
        ticks += `<span style="transform: rotate(${i * 6}deg) translateY(0); transform-origin: center calc(50% + 0px); height: ${long ? 14 : 7}px; width: ${long ? 2 : 1}px; left: calc(50% - ${long ? 1 : 0.5}px); top: 6px; background: rgba(0,0,0,${long ? 0.7 : 0.4});"></span>`;
      }
      let nums = '';
      for (let i = 0; i < 12; i++) {
        const angle = i * 30;
        nums += `<span style="transform: translate(-50%, -50%) rotate(${angle}deg) translateY(-46%) rotate(${-angle}deg); top: 50%; left: 50%;">${i === 0 ? 12 : i}</span>`;
      }

      v.innerHTML = `
        <div class="au-vault__bg"></div>
        <div class="au-vault__noise"></div>

        <div class="au-vault__placard">
          <span class="pip"></span>
          <span>The Vault · Behind the Door</span>
        </div>

        <div class="au-vault__stage">
          <!-- Door (two leaves) -->
          <div class="au-vault__door">
            <div class="au-vault__leaf au-vault__leaf--l">
              <div class="au-vault__rivets --l">
                <span></span><span></span><span></span><span></span><span></span>
                <span></span><span></span><span></span>
              </div>
            </div>
            <div class="au-vault__leaf au-vault__leaf--r">
              <div class="au-vault__rivets --r">
                <span></span><span></span><span></span><span></span><span></span>
                <span></span><span></span><span></span>
              </div>
            </div>
          </div>

          <div class="au-vault__door-inscription">
            Auramika · No. 04
            <strong>The Vault</strong>
            Turn the dial · or scroll
          </div>

          <!-- Dial -->
          <div class="au-vault__dial-wrap">
            <button class="au-vault__dial" id="auDial" data-cursor="Turn" aria-label="Open the vault">
              <div class="au-vault__dial-ticks">${ticks}</div>
              <div class="au-vault__dial-numbers">${nums}</div>
              <div class="au-vault__dial-boss">A</div>
              <svg class="au-vault__dial-arc" viewBox="0 0 200 200">
                <defs>
                  <path id="auDialArc" d="M 100,100 m -82,0 a 82,82 0 1,1 164,0 a 82,82 0 1,1 -164,0" />
                </defs>
                <text>
                  <textPath href="#auDialArc" startOffset="0">
                    Auramika · The Vault · Aura made &amp; mika · The Vault ·
                  </textPath>
                </text>
              </svg>
              <div class="au-vault__dial-instruction">Click to Open</div>
            </button>
          </div>

          <!-- Interior -->
          <div class="au-vault__interior">
            <!-- Time-lock HUD -->
            <div class="au-vault__hud">
              <div class="au-hud-cell">
                <div class="k">Mumbai · IST</div>
                <div class="v" id="vaTime">—</div>
              </div>
              <div class="au-hud-cell">
                <div class="k">22k Gold</div>
                <div class="v" id="vaGold">₹7,184<small>/g</small></div>
              </div>
              <div class="au-hud-cell">
                <div class="k">Patrons</div>
                <div class="v"><span id="vaPatrons">128</span><small>online</small></div>
              </div>
              <div class="au-hud-cell">
                <div class="k">In Your Aura</div>
                <div class="v" id="vaMood">Devotion</div>
              </div>
              <div class="au-hud-cell --full">
                <div class="k">Cart Locked At</div>
                <div class="v" id="vaLock">₹ 0 · for 12:00</div>
              </div>
            </div>

            <!-- Left: ledger + founder note -->
            <div class="au-vault__left">
              <span class="au-vault__chapter">Chapter IV · The Vault</span>
              <h2 class="au-vault__title">A house with a <em>back room</em>.</h2>

              <!-- Ledger -->
              <div class="au-ledger" id="auLedger">
                <div class="au-ledger__spine"></div>
                <div class="au-ledger__page">
                  <div class="au-ledger__chapter">The Patrons' Ledger · 1948 →</div>
                  <h4>Sign your name in the book.</h4>
                  <p>One letter a month. New drops, atelier visits, our quietest pieces — sent only to those whose name lives in this ledger.</p>
                  <form class="au-ledger__form" id="auLedgerForm">
                    <input type="email" placeholder="your name, by email…" required />
                    <button type="submit" data-cursor="Sign">Sign</button>
                  </form>
                  <div class="au-ledger__seal">A</div>
                </div>
              </div>

              <!-- Founder's note -->
              <div class="au-note" id="auNote">
                <span id="auNoteText">A piece of Auramika is not bought. It is chosen, the way one chooses a name.</span>
                <span class="au-note__sig">— Aanya R., Founder</span>
              </div>
            </div>

            <!-- Right: museum exhibits -->
            <div class="au-vault__right">
              <span class="au-vault__chapter">Exhibits · Our Doors</span>
              <h2 class="au-vault__title" style="font-size: clamp(28px, 3vw, 38px); max-width: 18ch;">Pick a <em>door</em> in the back room.</h2>

              <div class="au-exhibits">
                <a class="au-exhibit" href="products.html" data-cursor="Enter">
                  <span class="au-exhibit__num">No. 01</span>
                  <h4 class="au-exhibit__name">The Apothecary</h4>
                  <p class="au-exhibit__desc">Every drawer · all pieces</p>
                  <span class="au-exhibit__arrow">→</span>
                </a>
                <a class="au-exhibit" href="custom-order.html" data-cursor="Begin">
                  <span class="au-exhibit__num">No. 02</span>
                  <h4 class="au-exhibit__name">Bespoke</h4>
                  <p class="au-exhibit__desc">Sketch · 21 days · yours</p>
                  <span class="au-exhibit__arrow">→</span>
                </a>
                <a class="au-exhibit" href="face_ar.html" data-cursor="Try">
                  <span class="au-exhibit__num">No. 03</span>
                  <h4 class="au-exhibit__name">AR Studio</h4>
                  <p class="au-exhibit__desc">Try in real light</p>
                  <span class="au-exhibit__arrow">→</span>
                </a>
                <a class="au-exhibit" href="shops.html" data-cursor="Visit">
                  <span class="au-exhibit__num">No. 04</span>
                  <h4 class="au-exhibit__name">Atelier Partners</h4>
                  <p class="au-exhibit__desc">9 cities · master jewellers</p>
                  <span class="au-exhibit__arrow">→</span>
                </a>
                <a class="au-exhibit" href="index.html#mirror" data-cursor="Mirror">
                  <span class="au-exhibit__num">No. 05</span>
                  <h4 class="au-exhibit__name">Re-Mirror My Aura</h4>
                  <p class="au-exhibit__desc">Refresh your recipe</p>
                  <span class="au-exhibit__arrow">→</span>
                </a>
                <a class="au-exhibit" href="profile.html" data-cursor="Open">
                  <span class="au-exhibit__num">No. 06</span>
                  <h4 class="au-exhibit__name">Your House</h4>
                  <p class="au-exhibit__desc">Orders · holds · ledger</p>
                  <span class="au-exhibit__arrow">→</span>
                </a>
                <a class="au-exhibit au-exhibit--wide" href="https://wa.me/919999999999" target="_blank" data-cursor="Chat">
                  <span class="au-exhibit__num">No. 07</span>
                  <h4 class="au-exhibit__name">WhatsApp the House <span style="font-size:12px; color: rgba(255,252,245,0.45); margin-left:8px; letter-spacing:0.18em; text-transform:uppercase;">— a master jeweller replies</span></h4>
                  <p class="au-exhibit__desc">+91 9999 99 9999 · 9am–9pm IST</p>
                  <span class="au-exhibit__arrow">→</span>
                </a>
              </div>
            </div>
          </div>

          <!-- Closing brass card -->
          <div class="au-vault__seal">
            <button class="au-vault__close" id="auVaultClose" data-cursor="Close">Close The Vault</button>

            <div class="au-vault__seal-meta">
              <strong>Auramika</strong><br>
              The first jewellery house<br>
              that mirrors you.
            </div>

            <div class="au-vault__seal-mark">
              <svg viewBox="0 0 480 80" xmlns="http://www.w3.org/2000/svg">
                <text x="240" y="60" text-anchor="middle" class="au-mark-text">Auramika</text>
              </svg>
              <div style="font-size:10px; letter-spacing:0.4em; text-transform:uppercase; color: rgba(255,252,245,0.4); margin-top: 8px; font-weight: 600;">Vault · No. 04 · India</div>
            </div>

            <div class="au-vault__seal-meta --right">
              <strong>BIS 6-Digit Hallmark</strong><br>
              <strong>HDFC Bank · Insured</strong><br>
              <strong>2026 · All rights reserved</strong>
            </div>
          </div>
        </div>

        <!-- Cities ribbon -->
        <div class="au-vault__cities" aria-hidden="true">
          <div class="au-vault__cities-track">
            <span class="city">Mumbai</span><span class="city">Jaipur</span><span class="city">Bengaluru</span>
            <span class="city">Delhi</span><span class="city">Hyderabad</span><span class="city">Kochi</span>
            <span class="city">Chennai</span><span class="city">Kolkata</span><span class="city">Ahmedabad</span>
            <span class="city">Mumbai</span><span class="city">Jaipur</span><span class="city">Bengaluru</span>
            <span class="city">Delhi</span><span class="city">Hyderabad</span><span class="city">Kochi</span>
            <span class="city">Chennai</span><span class="city">Kolkata</span><span class="city">Ahmedabad</span>
          </div>
        </div>

        <div class="au-vault__sig">
          <span>v4 · The Vault · India 2026</span>
          <span class="legal">
            <a href="privacy.html">Privacy</a>
            <a href="terms.html">Terms</a>
            <a href="returns.html">Returns</a>
            <a href="refund-policy.html">Refunds</a>
            <a href="shipping-policy.html">Shipping</a>
            <a href="compliance.html">Compliance</a>
            <a href="account-deletion.html">Delete account</a>
            <a href="support.html">Support</a>
            <a href="app-download.html">Get the app</a>
          </span>
        </div>
      `;
      document.body.appendChild(v);
      initVault(v);
    }

    // ---------- Toast ----------
    if (!document.getElementById('auToast')) {
      const t = document.createElement('div');
      t.className = 'au-toast'; t.id = 'auToast';
      t.innerHTML = `<span class="check">✓</span><span id="auToastMsg">Saved</span>`;
      document.body.appendChild(t);
    }

    // ---------- Custom cursor + magnetic + loupe + karat init (mini) ----------
    initCursor();
    initLoupe();
    initKarat();
    hydrateAura();
  }

  // -----------------------------------------------------------
  // Cursor
  // -----------------------------------------------------------
  function initCursor() {
    const cursor = document.getElementById('auCursor');
    const dot = document.getElementById('auCursorDot');
    if (!cursor || !dot) return;
    if (window.matchMedia('(max-width: 900px)').matches) return;

    let mx = innerWidth/2, my = innerHeight/2;
    let cx = mx, cy = my, dx = mx, dy = my;
    addEventListener('mousemove', (e) => { mx = e.clientX; my = e.clientY; });
    (function tick() {
      cx += (mx - cx) * 0.18;
      cy += (my - cy) * 0.18;
      dx += (mx - dx) * 0.55;
      dy += (my - dy) * 0.55;
      cursor.style.transform = `translate3d(${cx}px,${cy}px,0) translate(-50%,-50%)`;
      dot.style.transform    = `translate3d(${dx}px,${dy}px,0) translate(-50%,-50%)`;
      requestAnimationFrame(tick);
    })();

    document.querySelectorAll('a, button, [data-cursor]').forEach(el => {
      const lab = el.dataset.cursor;
      el.addEventListener('mouseenter', () => {
        cursor.classList.add('is-hover');
        if (lab) cursor.dataset.label = lab;
      });
      el.addEventListener('mouseleave', () => {
        cursor.classList.remove('is-hover');
        cursor.dataset.label = 'Look';
      });
    });
  }

  // -----------------------------------------------------------
  // Loupe (cursor-following 6× zoom over .has-loupe)
  // -----------------------------------------------------------
  function initLoupe() {
    const loupe = document.getElementById('auLoupe');
    if (!loupe) return;
    if (window.matchMedia('(max-width: 900px)').matches) return;
    let active = null;
    addEventListener('mousemove', (e) => {
      if (!active) return;
      const r = active.getBoundingClientRect();
      const ix = (e.clientX - r.left) / r.width;
      const iy = (e.clientY - r.top) / r.height;
      if (ix < 0 || ix > 1 || iy < 0 || iy > 1) { loupe.classList.remove('is-active'); return; }
      loupe.classList.add('is-active');
      loupe.style.left = e.clientX + 'px';
      loupe.style.top  = e.clientY + 'px';
      loupe.style.backgroundPosition = `${ix * 100}% ${iy * 100}%`;
    });
    document.querySelectorAll('.has-loupe').forEach(el => {
      el.addEventListener('mouseenter', () => {
        active = el;
        const img = el.querySelector('img');
        if (img) loupe.style.backgroundImage = `url("${img.src}")`;
        loupe.dataset.karat = el.dataset.karat || '22k · BIS';
      });
      el.addEventListener('mouseleave', () => { active = null; loupe.classList.remove('is-active'); });
    });
  }

  // -----------------------------------------------------------
  // Karat ribbon
  // -----------------------------------------------------------
  function initKarat() {
    const rEl = document.getElementById('krRate');
    const dEl = document.getElementById('krDelta');
    const cEl = document.getElementById('krCart');
    if (!rEl) return;
    let rate = 7184, prev = 7172;
    function tick() {
      const drift = (Math.random() - 0.5) * 6;
      rate = Math.max(7100, Math.min(7300, Math.round(rate + drift)));
      const delta = rate - prev;
      const pct = ((delta / prev) * 100).toFixed(2);
      rEl.textContent = rate.toLocaleString('en-IN');
      dEl.innerHTML = `${delta >= 0 ? '▲' : '▼'} ${Math.abs(delta)} (${Math.abs(pct)}%) today`;
      dEl.classList.toggle('is-down', delta < 0);
      const cartTotal = (window.AURA && window.AURA.cartTotal()) || 0;
      cEl.textContent = '₹ ' + Math.round(cartTotal * (rate/7184)).toLocaleString('en-IN');
    }
    tick();
    setInterval(tick, 2400);
    addEventListener('auramika:cart', tick);
  }

  // -----------------------------------------------------------
  // The Vault — dial spin, door open/close, scroll-driven open,
  // time-lock HUD, founder note rotation, ledger seal, vault clunk
  // -----------------------------------------------------------
  function initVault(vault) {
    const dial      = document.getElementById('auDial');
    const closeBtn  = document.getElementById('auVaultClose');
    const ledgerEl  = document.getElementById('auLedger');
    const ledgerForm= document.getElementById('auLedgerForm');
    const noteEl    = document.getElementById('auNoteText');

    let opened = false;
    let dialAngle = 0;

    function open() {
      if (opened) return;
      opened = true;
      vault.classList.add('is-open');
      dial?.style.setProperty('--dial-rotation', (dialAngle + 720) + 'deg');
      dialAngle += 720;
      playClunk();
    }
    function close() {
      if (!opened) return;
      opened = false;
      vault.classList.remove('is-open');
      dial?.style.setProperty('--dial-rotation', (dialAngle - 360) + 'deg');
      dialAngle -= 360;
      playClunk(0.6);
    }

    dial?.addEventListener('click', () => opened ? close() : open());
    closeBtn?.addEventListener('click', () => {
      close();
      window.scrollTo({ top: vault.offsetTop - window.innerHeight, behavior: 'smooth' });
    });

    // Mouse over dial → small rotation tracking
    dial?.addEventListener('mousemove', (e) => {
      if (opened) return;
      const r = dial.getBoundingClientRect();
      const cx = r.left + r.width / 2;
      const cy = r.top + r.height / 2;
      const ang = Math.atan2(e.clientY - cy, e.clientX - cx) * (180 / Math.PI);
      dial.style.setProperty('--dial-rotation', (dialAngle + ang * 0.3) + 'deg');
    });

    // Scroll-driven auto-open: when vault top is ~50% into viewport
    function checkScroll() {
      if (!vault) return;
      const r = vault.getBoundingClientRect();
      const trigger = window.innerHeight * 0.55;
      if (r.top < trigger && !opened) open();
      else if (r.top > window.innerHeight && opened) close();
    }
    window.addEventListener('scroll', checkScroll, { passive: true });

    // Time
    const tEl = document.getElementById('vaTime');
    function pad(n) { return n < 10 ? '0' + n : '' + n; }
    function tickTime() {
      if (!tEl) return;
      const d = new Date(new Date().toLocaleString('en-US', { timeZone: 'Asia/Kolkata' }));
      tEl.textContent = `${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
    }
    setInterval(tickTime, 1000); tickTime();

    // Patrons
    let patrons = 120 + Math.floor(Math.random() * 30);
    const pEl = document.getElementById('vaPatrons');
    setInterval(() => {
      if (!pEl) return;
      patrons += Math.round((Math.random() - 0.5) * 3);
      patrons = Math.max(80, Math.min(220, patrons));
      pEl.textContent = patrons;
    }, 3200);

    // Mirror karat ribbon → gold + cart-lock countdown
    const gEl = document.getElementById('vaGold');
    const lockEl = document.getElementById('vaLock');
    let lockSeconds = 12 * 60;
    function syncHud() {
      const r = document.getElementById('krRate')?.textContent;
      if (gEl && r) gEl.innerHTML = `₹${r}<small>/g</small>`;
      const c = document.getElementById('krCart')?.textContent || '₹ 0';
      const m = pad(Math.floor(lockSeconds / 60));
      const s = pad(lockSeconds % 60);
      if (lockEl) lockEl.textContent = `${c} · for ${m}:${s}`;
    }
    setInterval(() => { lockSeconds = Math.max(0, lockSeconds - 1); syncHud(); }, 1000);
    addEventListener('auramika:cart', () => { lockSeconds = 12 * 60; syncHud(); });
    syncHud();

    // Mood label from saved aura
    const mEl = document.getElementById('vaMood');
    let aura = {};
    try { aura = JSON.parse(localStorage.getItem(STORE) || '{}'); } catch (e) {}
    if (mEl) mEl.textContent = aura.mood || 'Devotion';

    // Founder note rotation
    const NOTES = [
      ['A piece of Auramika is not bought. It is chosen, the way one chooses a name.', '— Aanya R., Founder'],
      ['We do not chase trends. We chase the moment a piece becomes an heirloom.', '— The House Rule'],
      ['The mirror reads you first. The drawer opens second. The piece arrives third.', '— Devkala, Master Jeweller, Mumbai'],
      ['Loud things rust. Quiet things last. Wear something quiet.', '— Aanya R.'],
    ];
    const idx = Math.floor(Math.random() * NOTES.length);
    if (noteEl) {
      noteEl.textContent = NOTES[idx][0];
      const sig = noteEl.parentElement.querySelector('.au-note__sig');
      if (sig) sig.textContent = NOTES[idx][1];
    }

    // Ledger sign
    ledgerForm?.addEventListener('submit', (e) => {
      e.preventDefault();
      ledgerForm.querySelector('input').value = '';
      ledgerEl?.classList.add('is-sealed');
      window.AURA?.toast('Signed in the patrons\' ledger');
      playPaper();
    });

    // Spotlight per-exhibit (cursor reactive)
    document.querySelectorAll('.au-exhibit').forEach(ex => {
      ex.addEventListener('mousemove', (e) => {
        const r = ex.getBoundingClientRect();
        ex.style.setProperty('--mx', ((e.clientX - r.left) / r.width * 100) + '%');
        ex.style.setProperty('--my', ((e.clientY - r.top) / r.height * 100) + '%');
      });
    });
  }

  // ---- Web Audio: vault clunk + paper flip ----
  let _ax;
  function _ctx() {
    if (!_ax) {
      try { _ax = new (window.AudioContext || window.webkitAudioContext)(); } catch (e) { return null; }
    }
    if (_ax.state === 'suspended') _ax.resume();
    return _ax;
  }
  function playClunk(scale = 1) {
    const ctx = _ctx();
    if (!ctx) return;
    const now = ctx.currentTime;
    const buf = ctx.createBuffer(1, ctx.sampleRate * 0.35, ctx.sampleRate);
    const d = buf.getChannelData(0);
    for (let i = 0; i < d.length; i++) {
      d[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / d.length, 2.6);
    }
    const src = ctx.createBufferSource(); src.buffer = buf;
    const lp = ctx.createBiquadFilter(); lp.type = 'lowpass'; lp.frequency.value = 220 * scale; lp.Q.value = 8;
    const gain = ctx.createGain();
    gain.gain.setValueAtTime(0.5 * scale, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.35);
    src.connect(lp).connect(gain).connect(ctx.destination);
    src.start(now);

    // Add a low resonant thunk
    const osc = ctx.createOscillator(); osc.type = 'sine'; osc.frequency.value = 60;
    const og = ctx.createGain();
    og.gain.setValueAtTime(0.3 * scale, now);
    og.gain.exponentialRampToValueAtTime(0.001, now + 0.5);
    osc.connect(og).connect(ctx.destination);
    osc.start(now); osc.stop(now + 0.5);
  }
  function playPaper() {
    const ctx = _ctx();
    if (!ctx) return;
    const now = ctx.currentTime;
    const buf = ctx.createBuffer(1, ctx.sampleRate * 0.25, ctx.sampleRate);
    const d = buf.getChannelData(0);
    for (let i = 0; i < d.length; i++) {
      d[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / d.length, 1.3);
    }
    const src = ctx.createBufferSource(); src.buffer = buf;
    const hp = ctx.createBiquadFilter(); hp.type = 'highpass'; hp.frequency.value = 1800;
    const gain = ctx.createGain();
    gain.gain.setValueAtTime(0.18, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.25);
    src.connect(hp).connect(gain).connect(ctx.destination);
    src.start(now);
  }

  // -----------------------------------------------------------
  // Persistent Aura state (mood, name, cart) shared across pages
  // -----------------------------------------------------------
  const STORE = 'auramika.aura.v1';
  const CART  = 'auramika.cart.v1';

  function hydrateAura() {
    let aura = {};
    try { aura = JSON.parse(localStorage.getItem(STORE)) || {}; } catch (e) {}
    if (aura.mood) {
      const map = {
        Devotion: '#E5BB55', Defiance: '#C7263A', Quiet: '#7A93BD',
        Bridal: '#D9446A', Inheritance: '#9A7B3D', Renewal: '#3F8E5C',
      };
      const hex = map[aura.mood] || '#E5BB55';
      document.documentElement.style.setProperty('--current-aura', hex);
    }
    if (aura.name) {
      const seal = (aura.name||'A').trim().charAt(0).toUpperCase() || 'A';
      const acSeal = document.getElementById('acSeal');
      const acName = document.getElementById('acName');
      const acTone = document.getElementById('acTone');
      if (acSeal) acSeal.textContent = seal;
      if (acName) acName.textContent = aura.name;
      if (acTone) acTone.textContent = aura.mood || 'Devotion';
      document.getElementById('auAuraChip')?.classList.add('is-shown');
    }

    // Hydrate cart counter
    const cart = AURA.getCart();
    const cnt = document.getElementById('navCartCount');
    if (cnt) cnt.textContent = cart.length;
  }

  // -----------------------------------------------------------
  // Public AURA helper (cart, toasts, naming)
  // -----------------------------------------------------------
  window.AURA = window.AURA || {
    getCart() {
      try { return JSON.parse(localStorage.getItem(CART)) || []; } catch (e) { return []; }
    },
    setCart(list) {
      try { localStorage.setItem(CART, JSON.stringify(list)); } catch (e) {}
      const cnt = document.getElementById('navCartCount');
      if (cnt) cnt.textContent = list.length;
      dispatchEvent(new CustomEvent('auramika:cart'));
    },
    addToCart(item) {
      const list = this.getCart();
      list.push(Object.assign({ id: 'p' + Math.random().toString(36).slice(2,9), qty: 1 }, item));
      this.setCart(list);
      this.toast('Added to your apothecary');
    },
    removeFromCart(id) {
      this.setCart(this.getCart().filter(x => x.id !== id));
    },
    clearCart() { this.setCart([]); },
    cartTotal() { return this.getCart().reduce((s, x) => s + (x.price * (x.qty || 1)), 0); },
    toast(msg) {
      const t = document.getElementById('auToast');
      const m = document.getElementById('auToastMsg');
      if (!t || !m) return;
      m.textContent = msg;
      t.classList.add('is-shown');
      clearTimeout(this._tt);
      this._tt = setTimeout(() => t.classList.remove('is-shown'), 1900);
    },
    flyTo(srcImg, target) {
      if (!srcImg || !target) return;
      const a = srcImg.getBoundingClientRect();
      const b = target.getBoundingClientRect();
      const ghost = srcImg.cloneNode();
      Object.assign(ghost.style, {
        position: 'fixed', left: a.left+'px', top: a.top+'px',
        width: a.width+'px', height: a.height+'px',
        borderRadius: '12px', pointerEvents: 'none', zIndex: 11200,
        transition: 'transform .85s cubic-bezier(.7,0,.3,1), opacity .9s ease, border-radius .8s ease',
        boxShadow: '0 30px 60px rgba(0,0,0,0.5)', objectFit: 'cover'
      });
      document.body.appendChild(ghost);
      requestAnimationFrame(() => {
        const tx = (b.left+b.width/2) - (a.left+a.width/2);
        const ty = (b.top+b.height/2)  - (a.top+a.height/2);
        ghost.style.transform = `translate(${tx}px,${ty}px) scale(.05) rotate(20deg)`;
        ghost.style.opacity = '0';
        ghost.style.borderRadius = '50%';
      });
      setTimeout(() => ghost.remove(), 1000);
      target.animate(
        [{ transform:'rotate(2deg) scale(1)' },{ transform:'rotate(-1deg) scale(1.06)' },{ transform:'rotate(2deg) scale(1)' }],
        { duration: 500, easing: 'cubic-bezier(.7,0,.3,1)' }
      );
    },
  };

  if (document.readyState !== 'loading') inject();
  else document.addEventListener('DOMContentLoaded', inject);
})();
