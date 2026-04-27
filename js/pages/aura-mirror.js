/* ============================================================================
   AURAMIKA — The Aura Mirror Engine
   - Cursor-tracked smoke plume on canvas (mood-tinted)
   - Mood chips re-tint everything via --current-aura
   - 3-question takeover ritual → Aura Card output
   - Aura Card download (PNG via canvas)
   - Loupe (cursor-following 6× zoom)
   - Live Karat Ribbon (ticking 22k rate + cart bullion value)
   - localStorage persistence of aura
   ============================================================================ */

(function () {
  'use strict';

  const STORE_KEY = 'auramika.aura.v1';

  // -----------------------------------------------------------
  // Mood colour map (single source of truth)
  // -----------------------------------------------------------
  const MOODS = {
    Devotion:    { hex: '#E5BB55', skinDefault: 'sand',     line2: 'chosen for you.' },
    Defiance:    { hex: '#C7263A', skinDefault: 'cinnamon', line2: 'the ones that bite back.' },
    Quiet:       { hex: '#7A93BD', skinDefault: 'ivory',    line2: 'pieces that whisper.' },
    Bridal:      { hex: '#D9446A', skinDefault: 'honey',    line2: 'wedding heirlooms.' },
    Inheritance: { hex: '#9A7B3D', skinDefault: 'amber',    line2: 'pieces with memory.' },
    Renewal:     { hex: '#3F8E5C', skinDefault: 'honey',    line2: 'pieces for the new sky.' },
  };

  const QUOTES = {
    Devotion: '"A piece chosen the way one chooses a name."',
    Defiance: '"Worn as a small, daily mutiny."',
    Quiet:    '"Loud things rust. Quiet things last."',
    Bridal:   '"What we wear is what we promise."',
    Inheritance: '"Some pieces are not bought, they are remembered."',
    Renewal:  '"A piece for the version of you tomorrow."',
  };

  // Aura state
  const state = {
    mood: 'Devotion',
    weight: null,
    skin: null,
    name: '',
    serial: Math.floor(1000 + Math.random() * 8999),
    activeStep: 1,
    cart: [],
  };

  // -----------------------------------------------------------
  // Boot
  // -----------------------------------------------------------
  function ready(fn) {
    if (document.readyState !== 'loading') fn();
    else document.addEventListener('DOMContentLoaded', fn);
  }

  ready(() => {
    restore();
    setMood(state.mood, /*silent*/true);

    initPlume();
    initMoodChips();
    initAmpFollow();
    initTakeover();
    initLoupe();
    initKaratRibbon();
    initAuraChip();

    // If a saved aura exists, hydrate UI
    if (state.weight && state.skin && state.name) {
      buildCard();
      showAuraChip();
    }

    // Debug/demo auto-open (synchronous so headless screenshots catch it)
    const q = new URLSearchParams(location.search).get('open');
    const overlay = document.getElementById('auTakeover');
    if (q === 'mirror' && overlay) {
      overlay.classList.add('is-open');
      overlay.style.opacity = '1';
      overlay.style.pointerEvents = 'auto';
      goStep(1);
    }
    if (q === 'card' && overlay) {
      state.weight = state.weight || 'silk';
      state.skin   = state.skin   || 'honey';
      state.name   = state.name   || 'Aanya';
      overlay.classList.add('is-open');
      overlay.style.opacity = '1';
      overlay.style.pointerEvents = 'auto';
      buildCard();
      goStep(4);
      showAuraChip();
    }
  });

  // -----------------------------------------------------------
  // Persistence
  // -----------------------------------------------------------
  function persist() {
    try { localStorage.setItem(STORE_KEY, JSON.stringify(state)); } catch (e) {}
  }
  function restore() {
    try {
      const raw = localStorage.getItem(STORE_KEY);
      if (!raw) return;
      const saved = JSON.parse(raw);
      Object.assign(state, saved);
    } catch (e) {}
  }

  // -----------------------------------------------------------
  // Mood (single-knob colour change for whole brand)
  // -----------------------------------------------------------
  function setMood(name, silent) {
    if (!MOODS[name]) return;
    state.mood = name;
    const hex = MOODS[name].hex;
    document.querySelectorAll('[style*="--current-aura"]').forEach(el => {
      el.style.setProperty('--current-aura', hex);
    });
    // Also propagate to root so chips/buttons elsewhere pick it up
    document.documentElement.style.setProperty('--current-aura', hex);
    document.querySelector('.au-mirror')?.style.setProperty('--current-aura', hex);
    document.querySelector('.au-takeover')?.style.setProperty('--current-aura', hex);

    // Re-tint plume
    plumeTint = hexToRgb(hex);

    // Re-tint mood chip dots
    document.querySelectorAll('.au-mood').forEach(b => {
      b.style.setProperty('--mood', b.dataset.aura);
      b.classList.toggle('is-active', b.dataset.mood === name);
    });

    if (!silent) persist();
  }

  function initMoodChips() {
    document.querySelectorAll('.au-mood').forEach(btn => {
      btn.addEventListener('click', () => setMood(btn.dataset.mood));
      btn.addEventListener('mouseenter', () => {
        // Preview tint without committing
        const hex = btn.dataset.aura;
        plumeTint = hexToRgb(hex);
      });
      btn.addEventListener('mouseleave', () => {
        plumeTint = hexToRgb(MOODS[state.mood].hex);
      });
    });
  }

  // -----------------------------------------------------------
  // Cursor-driven ampersand glow
  // -----------------------------------------------------------
  function initAmpFollow() {
    const amp = document.getElementById('auAmp');
    if (!amp) return;
    document.addEventListener('mousemove', (e) => {
      const r = amp.getBoundingClientRect();
      const cx = r.left + r.width / 2;
      const cy = r.top + r.height / 2;
      const dx = (e.clientX - cx) / window.innerWidth;
      const dy = (e.clientY - cy) / window.innerHeight;
      amp.style.transform = `translate(${dx * 14}px, ${dy * 12}px) translateY(-0.06em) rotate(${-4 + dx * 6}deg)`;
    });
  }

  // -----------------------------------------------------------
  // Plume — cursor-trail smoke on canvas
  // -----------------------------------------------------------
  let plumeTint = hexToRgb('#E5BB55');
  let particles = [];
  let plumeMouse = { x: 0, y: 0, lastX: 0, lastY: 0, has: false };

  function initPlume() {
    const canvas = document.getElementById('auPlume');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    let dpr = Math.min(window.devicePixelRatio || 1, 2);

    function resize() {
      const rect = canvas.parentElement.getBoundingClientRect();
      canvas.width = rect.width * dpr;
      canvas.height = rect.height * dpr;
      canvas.style.width = rect.width + 'px';
      canvas.style.height = rect.height + 'px';
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    }
    resize();
    window.addEventListener('resize', resize);

    // Seed center
    plumeMouse.x = canvas.clientWidth / 2;
    plumeMouse.y = canvas.clientHeight / 2;

    canvas.parentElement.addEventListener('mousemove', (e) => {
      const r = canvas.getBoundingClientRect();
      plumeMouse.x = e.clientX - r.left;
      plumeMouse.y = e.clientY - r.top;
      plumeMouse.has = true;
    });

    function emit() {
      // Distance from last position so emission scales with movement
      const dx = plumeMouse.x - plumeMouse.lastX;
      const dy = plumeMouse.y - plumeMouse.lastY;
      const dist = Math.sqrt(dx*dx + dy*dy);
      const count = Math.min(8, 2 + Math.floor(dist / 12));
      for (let i = 0; i < count; i++) {
        const t = i / count;
        const x = plumeMouse.lastX + dx * t + (Math.random() - 0.5) * 8;
        const y = plumeMouse.lastY + dy * t + (Math.random() - 0.5) * 8;
        particles.push({
          x, y,
          vx: (Math.random() - 0.5) * 0.6 + dx * 0.04,
          vy: -0.4 - Math.random() * 0.6 + dy * 0.04,
          r: 30 + Math.random() * 80,
          life: 1,
          decay: 0.005 + Math.random() * 0.01,
        });
      }
      plumeMouse.lastX = plumeMouse.x;
      plumeMouse.lastY = plumeMouse.y;

      // Auto-drift if no mouse yet
      if (!plumeMouse.has && Math.random() < 0.4) {
        const cx = canvas.clientWidth / 2;
        const cy = canvas.clientHeight / 2;
        plumeMouse.x = cx + Math.sin(performance.now() * 0.0005) * 200;
        plumeMouse.y = cy + Math.cos(performance.now() * 0.0007) * 80;
      }

      // Cap particles
      if (particles.length > 220) particles.splice(0, particles.length - 220);
    }

    function draw() {
      ctx.globalCompositeOperation = 'source-over';
      ctx.fillStyle = 'rgba(11,10,8,0.08)';
      ctx.fillRect(0, 0, canvas.clientWidth, canvas.clientHeight);

      ctx.globalCompositeOperation = 'lighter';
      const [r,g,b] = plumeTint;
      for (const p of particles) {
        const grad = ctx.createRadialGradient(p.x, p.y, 0, p.x, p.y, p.r);
        const a = p.life * 0.55;
        grad.addColorStop(0, `rgba(${r},${g},${b},${a})`);
        grad.addColorStop(0.4, `rgba(${r},${g},${b},${a * 0.35})`);
        grad.addColorStop(1, `rgba(${r},${g},${b},0)`);
        ctx.fillStyle = grad;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        ctx.fill();

        p.x += p.vx;
        p.y += p.vy;
        p.r += 0.4;
        p.life -= p.decay;
      }
      particles = particles.filter(p => p.life > 0);
    }

    function loop() {
      emit();
      draw();
      requestAnimationFrame(loop);
    }
    loop();
  }

  // -----------------------------------------------------------
  // Takeover (3-question ritual)
  // -----------------------------------------------------------
  function initTakeover() {
    const overlay = document.getElementById('auTakeover');
    const openBtn = document.getElementById('auOpenMirror');
    const closeBtn = document.getElementById('auTakeoverClose');
    const navMirror = document.getElementById('navMirror');
    if (!overlay || !openBtn) return;

    const open = () => {
      overlay.classList.add('is-open');
      // sync mood colour to overlay
      overlay.style.setProperty('--current-aura', MOODS[state.mood].hex);
      goStep(1);
      document.body.style.overflow = 'hidden';
    };
    const close = () => {
      overlay.classList.remove('is-open');
      document.body.style.overflow = '';
    };
    openBtn.addEventListener('click', open);
    closeBtn.addEventListener('click', close);
    navMirror?.addEventListener('click', (e) => { e.preventDefault(); open(); });
    overlay.addEventListener('click', (e) => { if (e.target === overlay) close(); });
    document.addEventListener('keydown', (e) => { if (e.key === 'Escape') close(); });

    // Step 1: weights
    overlay.querySelectorAll('[data-step="1"] .au-weights button').forEach(b => {
      b.addEventListener('click', () => {
        overlay.querySelectorAll('[data-step="1"] .au-weights button').forEach(x => x.classList.remove('is-active'));
        b.classList.add('is-active');
        state.weight = b.dataset.val;
      });
    });

    // Step 2: skins
    overlay.querySelectorAll('[data-step="2"] .au-skin').forEach(b => {
      b.addEventListener('click', () => {
        overlay.querySelectorAll('[data-step="2"] .au-skin').forEach(x => x.classList.remove('is-active'));
        b.classList.add('is-active');
        state.skin = b.dataset.val;
      });
    });

    // Step 3: name
    const nameInput = overlay.querySelector('#auNameInput');
    nameInput?.addEventListener('input', () => { state.name = nameInput.value.trim(); });
    nameInput?.addEventListener('keydown', (e) => {
      if (e.key === 'Enter') {
        e.preventDefault();
        if (state.name) commitAndReveal();
      }
    });

    // Nav buttons
    overlay.querySelectorAll('.au-step__nav .next').forEach(b => b.addEventListener('click', () => {
      const cur = state.activeStep;
      if (cur === 1 && !state.weight) return shake('weights');
      if (cur === 2 && !state.skin)   return shake('skins');
      if (cur === 3) {
        if (!state.name) state.name = 'You';
        commitAndReveal();
        return;
      }
      goStep(cur + 1);
    }));
    overlay.querySelectorAll('.au-step__nav .back').forEach(b => b.addEventListener('click', () => {
      goStep(state.activeStep - 1);
    }));

    // Card actions
    overlay.querySelector('#auCardOpen')?.addEventListener('click', () => {
      close();
      document.getElementById('cabinet')?.scrollIntoView({ behavior: 'smooth' });
    });
    overlay.querySelector('#auCardSave')?.addEventListener('click', downloadAuraCard);
  }

  function shake(scope) {
    const el = document.querySelector(`[data-step="${state.activeStep}"] .au-${scope}`);
    if (!el) return;
    el.animate(
      [{ transform: 'translateX(0)' }, { transform: 'translateX(-10px)' }, { transform: 'translateX(8px)' }, { transform: 'translateX(0)' }],
      { duration: 350, easing: 'ease-in-out' }
    );
  }

  function goStep(n) {
    state.activeStep = n;
    document.querySelectorAll('.au-takeover .au-step, .au-takeover .au-card-reveal').forEach(s => s.classList.remove('is-active'));
    const target = document.querySelector(`.au-takeover [data-step="${n}"]`);
    target?.classList.add('is-active');
    document.querySelectorAll('.au-takeover__rail span').forEach(s => {
      s.classList.toggle('is-active', parseInt(s.dataset.step, 10) <= n);
    });
  }

  function commitAndReveal() {
    persist();
    buildCard();
    goStep(4);
    showAuraChip();
  }

  // -----------------------------------------------------------
  // Aura Card
  // -----------------------------------------------------------
  const ALL_PIECES = [
    'assets/images/gold_ring.jpg',
    'assets/images/Pendant1.jpg',
    'assets/images/Pendant1.2.jpg',
    'assets/images/Pendant1.3.jpg',
    'assets/images/Pendant1.4.jpg',
    'assets/images/Pendant1.5.jpg',
    'assets/images/earring1.jpg',
    'assets/images/Maang Tikka1.jpg',
    'assets/images/Maang Tikka1.1.jpg',
    'assets/images/Pattern Maang Tikka1.jpg',
    'assets/images/Starry Elegance Gold Anklet1.jpg',
    'assets/images/Starry Elegance Gold Anklet1.1.jpg',
    'assets/images/Lakshmi Waist Belt1.jpg',
    'assets/images/gold Nose Pin1.jpg',
    'assets/images/gold Nose Pin1.1.jpg',
  ];

  function buildCard() {
    const initials = (state.name || 'You').trim().charAt(0).toUpperCase() || 'A';
    const seal = `${initials}`;
    const no = `Aura · ${String(state.serial).padStart(3, '0')}`;
    const today = new Date().toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' });

    setText('auCardSeal', seal);
    setText('auCardChip', seal);
    setText('auCardName', state.name || 'You');
    setText('auCardNo', no);
    setText('auCardSerial', `No. ${String(state.serial).padStart(4, '0')}`);
    setText('auCardMood', state.mood);
    setText('auCardWeight', cap(state.weight || 'Silk'));
    setText('auCardSkin', cap(state.skin || MOODS[state.mood].skinDefault));
    setText('auCardDate', today);
    setText('auCardQuote', QUOTES[state.mood] || QUOTES.Devotion);
    setText('auGreetName', `${state.name || 'You'},`);
    setText('auCardLine2', MOODS[state.mood].line2);

    // Pieces grid (deterministic from name+mood)
    const seed = (state.name + state.mood).split('').reduce((a, c) => a + c.charCodeAt(0), 0);
    const grid = document.getElementById('auCardPieces');
    if (grid) {
      grid.innerHTML = '';
      for (let i = 0; i < 8; i++) {
        const idx = (seed + i * 7) % ALL_PIECES.length;
        const wrap = document.createElement('div');
        wrap.className = 'au-card-reveal__piece';
        wrap.innerHTML = `<img src="${ALL_PIECES[idx]}" alt="">`;
        grid.appendChild(wrap);
      }
    }

    // Aura chip
    const acSeal = document.getElementById('acSeal');
    const acName = document.getElementById('acName');
    const acTone = document.getElementById('acTone');
    if (acSeal) acSeal.textContent = seal;
    if (acName) acName.textContent = state.name || 'You';
    if (acTone) acTone.textContent = state.mood;
  }

  function showAuraChip() {
    document.getElementById('auAuraChip')?.classList.add('is-shown');
  }

  function initAuraChip() {
    document.getElementById('auAuraChip')?.addEventListener('click', () => {
      document.getElementById('auOpenMirror')?.click();
      // Re-show the card directly
      setTimeout(() => goStep(4), 200);
    });
  }

  // -----------------------------------------------------------
  // Aura Card → PNG download (canvas render)
  // -----------------------------------------------------------
  function downloadAuraCard() {
    const W = 1080, H = 1350;
    const c = document.createElement('canvas');
    c.width = W; c.height = H;
    const x = c.getContext('2d');

    // Paper bg
    const grad = x.createLinearGradient(0, 0, W, H);
    grad.addColorStop(0, '#FFFCF5');
    grad.addColorStop(0.6, '#F2EBDB');
    grad.addColorStop(1, '#E8DCC0');
    x.fillStyle = grad;
    x.fillRect(0, 0, W, H);

    // Inner border
    x.strokeStyle = 'rgba(186,138,44,0.45)';
    x.lineWidth = 2;
    x.strokeRect(60, 60, W - 120, H - 120);

    const ink = '#0B0A08';
    const aura = MOODS[state.mood].hex;

    // Header line
    x.fillStyle = '#6B4E00';
    x.font = '600 22px Inter, sans-serif';
    x.fillText('AURAMIKA · AURA CARD', 110, 130);
    x.textAlign = 'right';
    x.fillText(`No. ${String(state.serial).padStart(4, '0')}`, W - 110, 130);
    x.textAlign = 'left';

    // Seal
    x.fillStyle = aura;
    x.beginPath(); x.arc(160, 240, 60, 0, Math.PI * 2); x.fill();
    x.fillStyle = ink;
    x.font = 'italic 700 56px "Playfair Display", serif';
    x.textAlign = 'center';
    x.textBaseline = 'middle';
    const initials = (state.name || 'You').trim().charAt(0).toUpperCase() || 'A';
    x.fillText(initials, 160, 248);
    x.textAlign = 'left';
    x.textBaseline = 'alphabetic';

    // Name script
    x.fillStyle = ink;
    x.font = '400 180px Allura, cursive';
    x.fillText(state.name || 'You', 110, 470);

    // Aura · 0xx
    x.fillStyle = '#6B4E00';
    x.font = 'italic 600 28px "Playfair Display", serif';
    x.fillText(`Aura · ${String(state.serial).padStart(3, '0')}`, 110, 520);

    // Recipe rows
    const rows = [
      ['Mood', state.mood],
      ['Weight', cap(state.weight || 'Silk')],
      ['Skin', cap(state.skin || MOODS[state.mood].skinDefault)],
      ['Karat', '22k · Hallmarked'],
    ];
    let ry = 620;
    x.setLineDash([6, 6]);
    x.strokeStyle = 'rgba(186,138,44,0.5)';
    x.beginPath(); x.moveTo(110, 590); x.lineTo(W - 110, 590); x.stroke();
    rows.forEach((r, i) => {
      x.fillStyle = '#6B4E00';
      x.font = '700 22px Inter, sans-serif';
      x.fillText(r[0].toUpperCase(), 110, ry);
      x.fillStyle = ink;
      x.font = '700 24px Inter, sans-serif';
      x.textAlign = 'right';
      x.fillText(r[1].toUpperCase(), W - 110, ry);
      x.textAlign = 'left';
      ry += 50;
    });
    x.beginPath(); x.moveTo(110, ry - 16); x.lineTo(W - 110, ry - 16); x.stroke();
    x.setLineDash([]);

    // Quote
    x.fillStyle = 'rgba(11,10,8,0.78)';
    x.font = 'italic 500 38px "Playfair Display", serif';
    wrapText(x, QUOTES[state.mood] || QUOTES.Devotion, 110, ry + 60, W - 220, 50);

    // Footer
    x.fillStyle = '#6B4E00';
    x.font = '600 18px Inter, sans-serif';
    const today = new Date().toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' });
    x.fillText('ISSUED ' + today.toUpperCase(), 110, H - 130);
    x.textAlign = 'right';
    x.fillText('AURAMIKA · INDIA', W - 110, H - 130);
    x.textAlign = 'left';

    // Bottom seal chip
    x.fillStyle = aura;
    x.beginPath(); x.arc(W - 200, H - 250, 70, 0, Math.PI * 2); x.fill();
    x.fillStyle = ink;
    x.font = 'italic 600 64px "Playfair Display", serif';
    x.textAlign = 'center';
    x.textBaseline = 'middle';
    x.fillText(initials, W - 200, H - 240);

    c.toBlob((blob) => {
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `auramika-aura-${(state.name || 'you').toLowerCase().replace(/\s+/g, '-')}.png`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      setTimeout(() => URL.revokeObjectURL(url), 1000);
    }, 'image/png');
  }

  function wrapText(ctx, text, x, y, maxWidth, lineHeight) {
    const words = text.split(' ');
    let line = '';
    for (const w of words) {
      const test = line + w + ' ';
      if (ctx.measureText(test).width > maxWidth) {
        ctx.fillText(line, x, y);
        line = w + ' ';
        y += lineHeight;
      } else {
        line = test;
      }
    }
    ctx.fillText(line, x, y);
  }

  // -----------------------------------------------------------
  // Loupe (cursor-following 6× zoom over .has-loupe)
  // -----------------------------------------------------------
  function initLoupe() {
    const loupe = document.getElementById('auLoupe');
    if (!loupe) return;
    if (window.matchMedia('(max-width: 900px)').matches) return;

    let active = null;
    const onMove = (e) => {
      if (!active) return;
      const r = active.getBoundingClientRect();
      const insideX = (e.clientX - r.left) / r.width;
      const insideY = (e.clientY - r.top) / r.height;
      if (insideX < 0 || insideX > 1 || insideY < 0 || insideY > 1) {
        loupe.classList.remove('is-active');
        return;
      }
      loupe.classList.add('is-active');
      loupe.style.left = e.clientX + 'px';
      loupe.style.top = e.clientY + 'px';
      loupe.style.backgroundPosition = `${insideX * 100}% ${insideY * 100}%`;
    };

    document.querySelectorAll('.has-loupe').forEach(el => {
      el.addEventListener('mouseenter', () => {
        active = el;
        const img = el.querySelector('img');
        if (img) {
          loupe.style.backgroundImage = `url("${img.src}")`;
        }
        loupe.dataset.karat = el.dataset.karat || '22k · BIS';
      });
      el.addEventListener('mouseleave', () => {
        active = null;
        loupe.classList.remove('is-active');
      });
    });

    document.addEventListener('mousemove', onMove);
  }

  // -----------------------------------------------------------
  // Live Karat Ribbon
  // -----------------------------------------------------------
  function initKaratRibbon() {
    const rEl = document.getElementById('krRate');
    const dEl = document.getElementById('krDelta');
    const cEl = document.getElementById('krCart');
    if (!rEl) return;

    let rate = 7184;
    let prev = 7172;
    function tick() {
      const drift = (Math.random() - 0.5) * 6;
      rate = Math.max(7100, Math.min(7300, Math.round(rate + drift)));
      const delta = rate - prev;
      const pct = ((delta / prev) * 100).toFixed(2);
      rEl.textContent = rate.toLocaleString('en-IN');
      dEl.innerHTML = `${delta >= 0 ? '▲' : '▼'} ${Math.abs(delta)} (${Math.abs(pct)}%) today`;
      dEl.classList.toggle('is-down', delta < 0);

      // cart bullion: sum of cart * (rate / 7184) heuristic (visual only)
      const cartTotal = state.cart.reduce((s, p) => s + p, 0);
      const adj = Math.round(cartTotal * (rate / 7184));
      cEl.textContent = '₹ ' + adj.toLocaleString('en-IN');
    }
    tick();
    setInterval(tick, 2400);

    // Listen for cart events from apothecary
    window.addEventListener('auramika:cart', (e) => {
      const price = e.detail?.price || 0;
      state.cart.push(price);
      tick();
    });
    window.addEventListener('auramika:cart-clear', () => {
      state.cart = [];
      tick();
    });
  }

  // -----------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------
  function setText(id, txt) { const el = document.getElementById(id); if (el) el.textContent = txt; }
  function cap(s) { return s ? s.charAt(0).toUpperCase() + s.slice(1) : s; }
  function hexToRgb(hex) {
    const m = hex.replace('#', '');
    const n = parseInt(m, 16);
    return [(n >> 16) & 255, (n >> 8) & 255, n & 255];
  }
})();
