/* Auramika legal/static page shell — slim nav + footer.
   Drop in: <script src="js/legal-shell.js" defer></script>
   Set <body data-page="privacy"> to highlight the active link if any. */
(function () {
  'use strict';

  function ready(fn) {
    if (document.readyState !== 'loading') fn();
    else document.addEventListener('DOMContentLoaded', fn);
  }

  ready(function () {
    var page = document.body.dataset.page || '';

    // ---------- Nav ----------
    if (!document.querySelector('.lp-nav')) {
      var nav = document.createElement('nav');
      nav.className = 'lp-nav';
      nav.innerHTML =
        '<a class="lp-nav__brand" href="index.html"><span class="dot"></span>Auramika</a>' +
        '<div class="lp-nav__links">' +
          '<a href="products.html">Apothecary</a>' +
          '<a href="shops.html">Jewellers</a>' +
          '<a href="custom-order.html">Bespoke</a>' +
          '<a href="support.html"' + (page === 'support' ? ' class="is-active"' : '') + '>Support</a>' +
        '</div>' +
        '<a class="lp-nav__cta" href="app-download.html">Get the App</a>';
      document.body.insertBefore(nav, document.body.firstChild);
    }

    // ---------- Footer ----------
    if (!document.querySelector('.lp-foot')) {
      var foot = document.createElement('footer');
      foot.className = 'lp-foot';
      foot.innerHTML =
        '<div class="lp-foot__grid">' +
          '<div class="lp-foot__col">' +
            '<span class="lp-foot__title">Help</span>' +
            '<a href="support.html">Contact &amp; Support</a>' +
            '<a href="shipping-policy.html">Shipping &amp; Delivery</a>' +
            '<a href="returns.html">Returns &amp; Exchange</a>' +
            '<a href="refund-policy.html">Refund &amp; Cancellation</a>' +
          '</div>' +
          '<div class="lp-foot__col">' +
            '<span class="lp-foot__title">Legal</span>' +
            '<a href="privacy.html">Privacy Policy</a>' +
            '<a href="terms.html">Terms of Use</a>' +
            '<a href="compliance.html">BIS &amp; Compliance</a>' +
            '<a href="account-deletion.html">Delete my account</a>' +
          '</div>' +
          '<div class="lp-foot__col">' +
            '<span class="lp-foot__title">House</span>' +
            '<a href="index.html">Home</a>' +
            '<a href="products.html">Apothecary</a>' +
            '<a href="shops.html">Atelier Partners</a>' +
            '<a href="custom-order.html">Bespoke</a>' +
            '<a href="face_ar.html">AR Studio</a>' +
            '<a href="profile.html">My Account</a>' +
          '</div>' +
          '<div class="lp-foot__col">' +
            '<span class="lp-foot__title">Get the App</span>' +
            '<a class="lp-foot__store" href="https://apps.apple.com/in/app/auramika/id0000000000" target="_blank" rel="noopener" aria-label="Download on the App Store">' +
              '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M16.365 1.43c0 1.14-.42 2.205-1.124 2.99-.84.943-2.21 1.65-3.32 1.564-.13-1.114.43-2.27 1.18-3.05.83-.86 2.245-1.5 3.264-1.504zm3.69 16.36c-.595 1.318-.882 1.91-1.65 3.07-1.06 1.61-2.55 3.62-4.4 3.64-1.65.02-2.07-1.07-4.31-1.06-2.24.01-2.7 1.08-4.35 1.06-1.85-.02-3.27-1.84-4.33-3.45C-.62 16.05-1.04 11.13 1.32 8.4c1.41-1.62 3.63-2.65 5.95-2.65 2.36 0 3.85 1.13 5.83 1.13 1.92 0 3.09-1.13 5.79-1.13 2.04 0 4.21.97 5.76 2.66-5.06 2.77-4.24 9.99 0.41 11.38z"/></svg>' +
              '<span><small>Download on the</small><strong>App Store</strong></span>' +
            '</a>' +
            '<a class="lp-foot__store" href="https://play.google.com/store/apps/details?id=in.auramika.app" target="_blank" rel="noopener" aria-label="Get it on Google Play">' +
              '<svg viewBox="0 0 24 24" aria-hidden="true">' +
                '<path d="M3.6 1.5c-.4.3-.6.8-.6 1.4v18.2c0 .6.2 1.1.6 1.4l10.5-10.5L3.6 1.5z" fill="#FFD400"/>' +
                '<path d="M14.1 12L17.5 8.6 4.6 1.1c-.3-.1-.7-.1-1 0L14.1 12z" fill="#48FF48"/>' +
                '<path d="M14.1 12L3.6 22.5c.3.1.7.1 1 0l12.9-7.5L14.1 12z" fill="#FF3838"/>' +
                '<path d="M21 10.5l-3.5-2-3.4 3.5 3.4 3.4 3.5-2c1-.6 1-2.3 0-2.9z" fill="#3CCBFF"/>' +
              '</svg>' +
              '<span><small>Get it on</small><strong>Google Play</strong></span>' +
            '</a>' +
          '</div>' +
        '</div>' +
        '<div class="lp-foot__sig">' +
          '<span>Auramika · India · ' + new Date().getFullYear() + '</span>' +
          '<span>BIS Hallmarked · Insured Shipping · Lifetime Workmanship</span>' +
        '</div>';
      document.body.appendChild(foot);
    }
  });
})();
