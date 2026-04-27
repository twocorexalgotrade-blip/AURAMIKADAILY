/* ============================================================
   AURAMIKA — Landing Page Motion
   Lenis smooth scroll · GSAP reveals · cursor · parallax
   ============================================================ */

(function () {
  'use strict';

  // ---------- Wait until libs are loaded ----------
  function ready(fn) {
    if (document.readyState !== 'loading') fn();
    else document.addEventListener('DOMContentLoaded', fn);
  }

  function whenLibs(cb, attempts = 60) {
    if (window.gsap && window.ScrollTrigger) return cb();
    if (attempts <= 0) return cb(); // give up gracefully
    setTimeout(() => whenLibs(cb, attempts - 1), 50);
  }

  ready(() => whenLibs(init));

  function init() {
    if (window.gsap && window.ScrollTrigger) {
      gsap.registerPlugin(ScrollTrigger);
    }

    bootLoader();
    smoothScroll();
    customCursor();
    stickyNav();
    revealOnScroll();
    parallaxFloats();
    countUp();
    magneticButtons();
    splitTextReveal();
  }

  // ---------- Loader ----------
  function bootLoader() {
    const loader = document.getElementById('auLoader');
    if (!loader) return;
    if (/[?&]nob=1\b/.test(location.search)) { loader.remove(); return; }
    const veil = loader.querySelector('.au-loader__veil');

    // After bar finishes (~1.6s), sweep the veil down then hide loader.
    setTimeout(() => {
      if (window.gsap) {
        gsap.to(veil, {
          scaleY: 1,
          duration: 0.9,
          ease: 'expo.inOut',
          onComplete: () => {
            gsap.to(loader, {
              autoAlpha: 0,
              duration: 0.4,
              onComplete: () => loader.remove()
            });
          }
        });
      } else {
        loader.style.transition = 'opacity .5s ease';
        loader.style.opacity = '0';
        setTimeout(() => loader.remove(), 500);
      }
    }, 1700);
  }

  // ---------- Lenis smooth scroll ----------
  function smoothScroll() {
    if (!window.Lenis) return;
    const lenis = new Lenis({
      duration: 1.15,
      easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
      smoothWheel: true,
      lerp: 0.1,
    });
    function raf(t) { lenis.raf(t); requestAnimationFrame(raf); }
    requestAnimationFrame(raf);

    if (window.ScrollTrigger) {
      lenis.on('scroll', ScrollTrigger.update);
    }
    window.__auLenis = lenis;
  }

  // ---------- Custom cursor ----------
  function customCursor() {
    const cursor = document.getElementById('auCursor');
    const dot = document.getElementById('auCursorDot');
    if (!cursor || !dot) return;
    if (window.matchMedia('(max-width: 900px)').matches) return;

    let mx = window.innerWidth / 2, my = window.innerHeight / 2;
    let cx = mx, cy = my, dx = mx, dy = my;

    window.addEventListener('mousemove', (e) => { mx = e.clientX; my = e.clientY; });

    function tick() {
      cx += (mx - cx) * 0.18;
      cy += (my - cy) * 0.18;
      dx += (mx - dx) * 0.55;
      dy += (my - dy) * 0.55;
      cursor.style.transform = `translate3d(${cx}px, ${cy}px, 0) translate(-50%, -50%)`;
      dot.style.transform = `translate3d(${dx}px, ${dy}px, 0) translate(-50%, -50%)`;
      requestAnimationFrame(tick);
    }
    tick();

    document.querySelectorAll('[data-cursor], a, button').forEach(el => {
      const label = el.dataset.cursor;
      el.addEventListener('mouseenter', () => {
        cursor.classList.add('is-hover');
        if (label) cursor.dataset.label = label;
      });
      el.addEventListener('mouseleave', () => {
        cursor.classList.remove('is-hover');
        cursor.dataset.label = 'Explore';
      });
    });

    window.addEventListener('mouseleave', () => { cursor.style.opacity = '0'; dot.style.opacity = '0'; });
    window.addEventListener('mouseenter', () => { cursor.style.opacity = '1'; dot.style.opacity = '1'; });
  }

  // ---------- Sticky nav state ----------
  function stickyNav() {
    const nav = document.getElementById('auNav');
    if (!nav) return;
    const onScroll = () => nav.classList.toggle('is-scrolled', window.scrollY > 60);
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
  }

  // ---------- Reveal on scroll ----------
  function revealOnScroll() {
    const items = document.querySelectorAll('.au-reveal');
    if (!('IntersectionObserver' in window)) {
      items.forEach(el => el.classList.add('is-visible'));
      return;
    }
    const io = new IntersectionObserver(entries => {
      entries.forEach(e => {
        if (e.isIntersecting) { e.target.classList.add('is-visible'); io.unobserve(e.target); }
      });
    }, { threshold: 0.18, rootMargin: '0px 0px -8% 0px' });
    items.forEach(el => io.observe(el));
  }

  // ---------- Hero floating images parallax ----------
  function parallaxFloats() {
    if (!window.gsap || !window.ScrollTrigger) return;
    const floats = document.querySelectorAll('[data-parallax]');
    floats.forEach(el => {
      const speed = parseFloat(el.dataset.parallax || '0.2');
      gsap.to(el, {
        yPercent: speed * 100,
        ease: 'none',
        scrollTrigger: {
          trigger: '.au-hero',
          start: 'top top',
          end: 'bottom top',
          scrub: true,
        }
      });
    });

    // Mouse parallax for hero floats
    const hero = document.querySelector('.au-hero');
    const group = document.querySelector('[data-parallax-group]');
    if (!hero || !group) return;
    hero.addEventListener('mousemove', (e) => {
      const r = hero.getBoundingClientRect();
      const x = (e.clientX - r.left) / r.width - 0.5;
      const y = (e.clientY - r.top) / r.height - 0.5;
      group.querySelectorAll('img').forEach((img, i) => {
        const depth = (i % 2 === 0 ? 1 : -1) * (10 + i * 3);
        img.style.transform = (img.style.transform.replace(/translate\([^)]+\)/, '') || '')
          + ` translate(${x * depth}px, ${y * depth}px)`;
      });
    });
  }

  // ---------- Number count-up ----------
  function countUp() {
    const els = document.querySelectorAll('[data-count]');
    if (!els.length) return;
    const io = new IntersectionObserver(entries => {
      entries.forEach(e => {
        if (!e.isIntersecting) return;
        const el = e.target;
        const target = parseInt(el.dataset.count, 10) || 0;
        const dur = 1600;
        const t0 = performance.now();
        function step(t) {
          const p = Math.min(1, (t - t0) / dur);
          const eased = 1 - Math.pow(1 - p, 3);
          el.textContent = Math.round(target * eased).toLocaleString();
          if (p < 1) requestAnimationFrame(step);
        }
        requestAnimationFrame(step);
        io.unobserve(el);
      });
    }, { threshold: 0.4 });
    els.forEach(el => io.observe(el));
  }

  // ---------- Magnetic buttons ----------
  function magneticButtons() {
    if (window.matchMedia('(max-width: 900px)').matches) return;
    document.querySelectorAll('.au-btn, .au-nav__cta, .au-app__store').forEach(btn => {
      btn.addEventListener('mousemove', (e) => {
        const r = btn.getBoundingClientRect();
        const x = e.clientX - r.left - r.width / 2;
        const y = e.clientY - r.top - r.height / 2;
        btn.style.transform = `translate(${x * 0.2}px, ${y * 0.25}px)`;
      });
      btn.addEventListener('mouseleave', () => {
        btn.style.transform = '';
      });
    });
  }

  // ---------- Hero title split-line reveal ----------
  function splitTextReveal() {
    const title = document.querySelector('.au-hero__title');
    if (!title) return;
    const rows = title.querySelectorAll('.row');
    rows.forEach((row, i) => {
      row.style.overflow = 'hidden';
      const inner = document.createElement('span');
      inner.style.display = 'inline-block';
      while (row.firstChild) inner.appendChild(row.firstChild);
      row.appendChild(inner);
      inner.style.transform = 'translateY(110%)';
      inner.style.transition = `transform 1.2s ${i === 0 ? '0.3s' : '0.55s'} cubic-bezier(.16,1,.3,1)`;
      requestAnimationFrame(() => {
        setTimeout(() => { inner.style.transform = 'translateY(0)'; }, 50);
      });
    });

    const sub = document.querySelector('.au-hero__sub');
    const cta = document.querySelector('.au-hero__cta-row');
    const eye = document.querySelector('.au-hero__eyebrow');
    [eye, sub, cta].forEach((el, i) => {
      if (!el) return;
      el.style.opacity = '0';
      el.style.transform = 'translateY(28px)';
      el.style.transition = `opacity .9s ${0.7 + i * 0.12}s ease, transform .9s ${0.7 + i * 0.12}s cubic-bezier(.16,1,.3,1)`;
      requestAnimationFrame(() => setTimeout(() => {
        el.style.opacity = '1';
        el.style.transform = 'none';
      }, 50));
    });
  }
})();
