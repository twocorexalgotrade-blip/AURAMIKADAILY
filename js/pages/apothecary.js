/* ============================================================================
   AURAMIKA — Apothecary Cabinet behavior
   - Accordion drawers (only one open at a time looks cleaner; multiple allowed)
   - Web Audio chime + soft "wood" thunk on open
   - Add-to-cart: piece flies into the karat ribbon, dispatches event for ribbon
   - Toast confirmation
   ============================================================================ */

(function () {
  'use strict';

  function ready(fn) {
    if (document.readyState !== 'loading') fn();
    else document.addEventListener('DOMContentLoaded', fn);
  }

  ready(() => {
    initDrawers();
    initAddToCart();
  });

  // -----------------------------------------------------------
  // Drawers
  // -----------------------------------------------------------
  function initDrawers() {
    document.querySelectorAll('.au-drawer').forEach(d => {
      const handle = d.querySelector('.au-drawer__handle');
      handle?.addEventListener('click', () => {
        const wasOpen = d.classList.contains('is-open');
        // Close siblings (cleaner look)
        d.parentElement.querySelectorAll('.au-drawer.is-open').forEach(o => o.classList.remove('is-open'));
        if (!wasOpen) {
          d.classList.add('is-open');
          playWood();
        }
      });
    });
  }

  // -----------------------------------------------------------
  // Add to cart
  // -----------------------------------------------------------
  function initAddToCart() {
    document.querySelectorAll('.au-piece__add').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        if (btn.classList.contains('is-added')) return;

        const price = parseInt(btn.dataset.price || '0', 10);
        const piece = btn.closest('.au-piece');
        const img = piece?.querySelector('img');

        // Fly the image to the karat ribbon
        if (img) flyTo(img, document.getElementById('auKarat'));

        // Dispatch cart event for the ribbon
        window.dispatchEvent(new CustomEvent('auramika:cart', { detail: { price } }));

        // Mark added briefly
        btn.classList.add('is-added');
        btn.textContent = '✓';
        setTimeout(() => {
          btn.classList.remove('is-added');
          btn.textContent = '+';
        }, 1800);

        // Chime
        playChime();

        // Toast
        showToast('Added to your apothecary');
      });
    });
  }

  function flyTo(srcImg, target) {
    if (!srcImg || !target) return;
    const a = srcImg.getBoundingClientRect();
    const b = target.getBoundingClientRect();
    const ghost = srcImg.cloneNode();
    Object.assign(ghost.style, {
      position: 'fixed',
      left: a.left + 'px',
      top: a.top + 'px',
      width: a.width + 'px',
      height: a.height + 'px',
      borderRadius: '12px',
      pointerEvents: 'none',
      zIndex: 11200,
      transition: 'transform 0.85s cubic-bezier(.7,.0,.3,1), opacity .9s ease, border-radius .8s ease',
      boxShadow: '0 30px 60px rgba(0,0,0,0.5)',
      objectFit: 'cover',
    });
    document.body.appendChild(ghost);
    requestAnimationFrame(() => {
      const tx = (b.left + b.width / 2) - (a.left + a.width / 2);
      const ty = (b.top + b.height / 2) - (a.top + a.height / 2);
      ghost.style.transform = `translate(${tx}px, ${ty}px) scale(0.05) rotate(20deg)`;
      ghost.style.opacity = '0';
      ghost.style.borderRadius = '50%';
    });
    setTimeout(() => ghost.remove(), 1000);

    // Bounce karat ribbon
    target.animate(
      [{ transform: 'rotate(2deg) scale(1)' }, { transform: 'rotate(-1deg) scale(1.06)' }, { transform: 'rotate(2deg) scale(1)' }],
      { duration: 500, easing: 'cubic-bezier(.7,.0,.3,1)' }
    );
  }

  // -----------------------------------------------------------
  // Toast
  // -----------------------------------------------------------
  let toastTimeout = null;
  function showToast(msg) {
    const t = document.getElementById('auToast');
    const m = document.getElementById('auToastMsg');
    if (!t || !m) return;
    m.textContent = msg;
    t.classList.add('is-shown');
    clearTimeout(toastTimeout);
    toastTimeout = setTimeout(() => t.classList.remove('is-shown'), 1900);
  }

  // -----------------------------------------------------------
  // Web Audio — chime + wood thunk
  // -----------------------------------------------------------
  let audioCtx = null;
  function getCtx() {
    if (!audioCtx) {
      try { audioCtx = new (window.AudioContext || window.webkitAudioContext)(); }
      catch (e) { return null; }
    }
    if (audioCtx.state === 'suspended') audioCtx.resume();
    return audioCtx;
  }

  function playChime() {
    const ctx = getCtx();
    if (!ctx) return;
    const now = ctx.currentTime;
    // Two-note bell: 1320Hz (E6) + 1760Hz (A6) decaying
    [1320, 1760, 2640].forEach((f, i) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'sine';
      osc.frequency.value = f;
      gain.gain.setValueAtTime(0, now);
      gain.gain.linearRampToValueAtTime(0.08 / (i + 1), now + 0.005);
      gain.gain.exponentialRampToValueAtTime(0.0001, now + 1.4);
      osc.connect(gain).connect(ctx.destination);
      osc.start(now);
      osc.stop(now + 1.5);
    });
  }

  function playWood() {
    const ctx = getCtx();
    if (!ctx) return;
    const now = ctx.currentTime;
    // Short noise burst through low-pass = wood thunk
    const buffer = ctx.createBuffer(1, ctx.sampleRate * 0.18, ctx.sampleRate);
    const data = buffer.getChannelData(0);
    for (let i = 0; i < data.length; i++) {
      data[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / data.length, 2.4);
    }
    const src = ctx.createBufferSource();
    src.buffer = buffer;
    const lp = ctx.createBiquadFilter();
    lp.type = 'lowpass';
    lp.frequency.value = 380;
    lp.Q.value = 6;
    const gain = ctx.createGain();
    gain.gain.setValueAtTime(0.3, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.18);
    src.connect(lp).connect(gain).connect(ctx.destination);
    src.start(now);
  }
})();
