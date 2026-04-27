// ===================================
// SWARNA SETU - HEADER COMPONENT
// Header interactions and mobile menu
// ===================================

(function () {
    'use strict';

    // Header scroll effect
    const header = document.getElementById('header');

    function handleScroll() {
        if (!header) return;

        constscrollTop = window.pageYOffset || document.documentElement.scrollTop;

        // Add shadow on scroll
        if (scrollTop > 10) {
            header.classList.add('scrolled');
        } else {
            header.classList.remove('scrolled');
        }
    }

    // Throttle scroll event
    if (typeof Utils !== 'undefined' && Utils.throttle) {
        window.addEventListener('scroll', Utils.throttle(handleScroll, 100));
    } else {
        window.addEventListener('scroll', handleScroll);
    }

    // Mobile menu toggle
    const menuToggle = document.getElementById('menuToggle');
    const headerNav = document.getElementById('headerNav');

    if (menuToggle && headerNav) {
        menuToggle.addEventListener('click', (e) => {
            e.stopPropagation();
            menuToggle.classList.toggle('active');
            headerNav.classList.toggle('active');

            // Toggle body scroll
            document.body.style.overflow = headerNav.classList.contains('active') ? 'hidden' : '';
        });

        // Close menu when clicking outside
        document.addEventListener('click', (e) => {
            if (headerNav.classList.contains('active') &&
                !headerNav.contains(e.target) &&
                !menuToggle.contains(e.target)) {

                menuToggle.classList.remove('active');
                headerNav.classList.remove('active');
                document.body.style.overflow = '';
            }
        });

        // Close menu when clicking a link
        headerNav.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', () => {
                menuToggle.classList.remove('active');
                headerNav.classList.remove('active');
                document.body.style.overflow = '';
            });
        });
    }

    // Search button
    const searchBtn = document.getElementById('searchBtn');

    if (searchBtn) {
        searchBtn.addEventListener('click', () => {
            // Ideally toggle a search bar overlay
            const query = prompt("Search for jewelry (e.g., 'ring', 'gold'):");
            if (query) {
                window.location.href = `products.html?search=${encodeURIComponent(query)}`;
            }
        });
    }

    // Gold rate link
    const goldRateLink = document.getElementById('goldRateLink');
    if (goldRateLink) {
        goldRateLink.addEventListener('click', (e) => {
            e.preventDefault();
            if (typeof Utils !== 'undefined') {
                Utils.showToast('Today\'s Gold Rate: ₹6,850/gm (22K)', 'info');
            } else {
                alert('Today\'s Gold Rate: ₹6,850/gm (22K)');
            }
        });
    }

    // Highlight Active Link
    function highlightActiveLink() {
        const path = window.location.pathname;
        const page = path.split('/').pop() || 'index.html';

        // Header links
        const headerLinks = document.querySelectorAll('.header-nav-link');
        headerLinks.forEach(link => {
            const href = link.getAttribute('href');
            if (href === page || (page === '' && href === 'index.html')) {
                link.classList.add('active');
            } else {
                link.classList.remove('active');
            }
        });

        // Bottom nav links
        const bottomLinks = document.querySelectorAll('.bottom-nav-item');
        bottomLinks.forEach(link => {
            const href = link.getAttribute('href');
            if (href === page || (page === '' && href === 'index.html')) {
                link.classList.add('active');
            } else {
                link.classList.remove('active');
            }
        });
    }

    // Run on load
    highlightActiveLink();

})();
