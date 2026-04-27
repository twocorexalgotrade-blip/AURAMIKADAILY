// ===================================
// SWARNA SETU - PRODUCTS PAGE LOGIC
// Products listing, filtering, and sorting
// ===================================

(function () {
    'use strict';

    let allProducts = [];
    let currentCategory = 'all';
    let currentSort = 'newest';

    /**
     * Load products
     */
    async function loadProducts() {
        const container = document.getElementById('productsGrid');
        if (!container) return;

        // Mock product data
        const mockProducts = [
            { id: '1', name: 'Elegant Gold Pendant', vendorName: 'Tanishq', price: 45000, imageUrl: 'assets/images/Pendant1.jpg', purity: '22K', weightInGrams: 8.5, metal: 'Gold', category: 'pendants', date: '2025-01-15' },
            { id: '2', name: 'Diamond Earrings', vendorName: 'Bluestone', price: 32000, imageUrl: 'assets/images/earring1.jpg', purity: '18K', weightInGrams: 6.2, metal: 'Gold', category: 'earrings', date: '2025-02-01' },
            { id: '3', name: 'Gold Ring', vendorName: 'Giva', price: 28000, imageUrl: 'assets/images/gold_ring.jpg', purity: '22K', weightInGrams: 5.8, metal: 'Gold', category: 'rings', date: '2025-01-20' },
            { id: '4', name: 'Starry Elegance Anklet', vendorName: 'Shri Hari', price: 18000, imageUrl: 'assets/images/Starry Elegance Gold Anklet1.jpg', purity: '18K', weightInGrams: 4.2, metal: 'Gold', category: 'anklets', date: '2025-01-10' },
            { id: '5', name: 'Maang Tikka', vendorName: 'Anita Dongre', price: 22000, imageUrl: 'assets/images/Maang Tikka1.jpg', purity: '22K', weightInGrams: 3.5, metal: 'Gold', category: 'accessories', date: '2025-02-05' },
            { id: '6', name: 'Gold Nose Pin', vendorName: 'Cartier', price: 8500, imageUrl: 'assets/images/gold Nose Pin1.jpg', purity: '18K', weightInGrams: 1.2, metal: 'Gold', category: 'accessories', date: '2025-01-25' },
            { id: '7', name: 'Teardrop Diamond Pendant', vendorName: 'Tanishq', price: 55000, imageUrl: 'assets/images/Teardrop Shaped Yellow Gold and Diamond Pendant1.jpg', purity: '18K', weightInGrams: 7.8, metal: 'Gold', category: 'pendants', date: '2025-01-18' },
            { id: '8', name: 'Guardian Edge Pendant', vendorName: 'OP Jewellers', price: 42000, imageUrl: 'assets/images/Guardian Edge Diamond Pendant For Men1.jpg', purity: '18K', weightInGrams: 9.2, metal: 'Gold', category: 'pendants', date: '2025-01-30' },
            { id: '9', name: 'Indriya Necklace', vendorName: 'Indriya', price: 85000, imageUrl: 'assets/images/top_selling/indriya_necklace.jpg', purity: '22K', weightInGrams: 15.5, metal: 'Gold', category: 'necklaces', date: '2024-12-15' },
            { id: '10', name: 'Giva Gold Chain', vendorName: 'Giva', price: 38000, imageUrl: 'assets/images/top_selling/giva_gold_chain.jpg', purity: '18K', weightInGrams: 8.2, metal: 'Gold', category: 'chains', date: '2025-01-05' },
            { id: '11', name: 'Bluestone Silver Chain', vendorName: 'Bluestone', price: 12000, imageUrl: 'assets/images/top_selling/bluestone_silver_chain.jpg', purity: '925', weightInGrams: 10.5, metal: 'Silver', category: 'chains', date: '2025-01-12' },
            { id: '12', name: 'Kids Pendant', vendorName: 'Bluestone', price: 15000, imageUrl: 'assets/images/top_selling/bluestone_kids_pendant.jpg', purity: '18K', weightInGrams: 3.8, metal: 'Gold', category: 'pendants', date: '2025-01-22' }
        ];

        try {
            // Show skeletons
            container.innerHTML = '';
            for (let i = 0; i < 8; i++) {
                container.appendChild(createProductCardSkeleton());
            }

            // Get URL params for initial filter
            const urlParams = new URLSearchParams(window.location.search);
            const categoryParam = urlParams.get('category');
            if (categoryParam) {
                currentCategory = categoryParam;
                updateFilterUI(currentCategory);
            }

            // Fetch products
            // In a real app, we would pass filters to the API
            const response = await fetch(`${CONFIG.API_BASE_URL}/api/products`);

            if (!response.ok) {
                throw new Error('Failed to fetch products');
            }

            const data = await response.json();
            const fetchedProducts = data.products || data.data || [];

            allProducts = fetchedProducts.length > 0 ? fetchedProducts : mockProducts;

            // Render with initial filters
            filterAndRenderProducts();

        } catch (error) {
            console.error('Error loading products:', error);
            // Fallback to mock data
            allProducts = mockProducts;
            filterAndRenderProducts();
        }
    }

    /**
     * Update Filter UI based on current category
     */
    function updateFilterUI(category) {
        document.querySelectorAll('[data-filter]').forEach(btn => {
            if (btn.dataset.filter === category) {
                btn.classList.add('active');
                // Scroll into view if needed
                btn.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
            } else {
                btn.classList.remove('active');
            }
        });
    }

    /**
     * Filter and Render Products
     */
    function filterAndRenderProducts() {
        const container = document.getElementById('productsGrid');
        if (!container) return;

        container.innerHTML = '';

        let filtered = [...allProducts];

        // Filter by category
        if (currentCategory !== 'all') {
            filtered = filtered.filter(p => p.category === currentCategory || (p.category && p.category.toLowerCase().includes(currentCategory)));
        }

        // Sort
        filtered.sort((a, b) => {
            switch (currentSort) {
                case 'price_low':
                    return a.price - b.price;
                case 'price_high':
                    return b.price - a.price;
                case 'newest':
                    // Mock date sorting if date exists, otherwise random or id based
                    return (b.date || b.id) > (a.date || a.id) ? 1 : -1;
                case 'popular':
                default:
                    // Random shuffle for popular or just keeping order
                    return 0.5 - Math.random();
            }
        });

        if (filtered.length === 0) {
            container.innerHTML = `
                <div class="empty-state">
                    <span class="empty-icon">🔍</span>
                    <h3>No products found</h3>
                    <p>Try changing your filters or check back later.</p>
                </div>
            `;
            return;
        }

        filtered.forEach(product => {
            container.appendChild(createProductCard(product));
        });

        // Update page title if category selected
        const titleEl = document.querySelector('.page-title');
        if (titleEl) {
            if (currentCategory === 'all') {
                titleEl.textContent = 'All Collections';
            } else {
                // Capitalize first letter
                titleEl.textContent = currentCategory.charAt(0).toUpperCase() + currentCategory.slice(1);
            }
        }
    }

    /**
     * Setup Filters
     */
    function setupFilters() {
        // Category chips
        document.querySelectorAll('[data-filter]').forEach(btn => {
            btn.addEventListener('click', () => {
                const filter = btn.dataset.filter;
                currentCategory = filter;

                // Update UI
                updateFilterUI(currentCategory);

                // Update URL without reload
                const newUrl = new URL(window.location);
                if (filter === 'all') {
                    newUrl.searchParams.delete('category');
                } else {
                    newUrl.searchParams.set('category', filter);
                }
                window.history.pushState({}, '', newUrl);

                filterAndRenderProducts();
            });
        });

        // Sort select
        const sortSelect = document.getElementById('sortSelect');
        if (sortSelect) {
            sortSelect.addEventListener('change', (e) => {
                currentSort = e.target.value;
                filterAndRenderProducts();
            });
        }
    }

    /**
     * Initialize
     */
    function init() {
        console.log('🛍️ Initializing products page...');
        loadProducts();
        setupFilters();
    }

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();
