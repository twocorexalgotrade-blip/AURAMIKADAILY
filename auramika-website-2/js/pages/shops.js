// ===================================
// SWARNA SETU - SHOPS PAGE LOGIC
// Shops listing
// ===================================

(function () {
    'use strict';

    /**
     * Load shops
     */
    async function loadShops() {
        const container = document.getElementById('shopsGrid');
        if (!container) return;

        // Mock shop data
        const mockShops = [
            { id: '1', name: 'Tanishq', location: 'Mumbai, Maharashtra', logoUrl: 'assets/images/popular_jewellers/tanishq_logo.png', productCount: 250, rating: 4.8 },
            { id: '2', name: 'Shri Hari Jewellers', location: 'Surat, Gujarat', logoUrl: 'assets/images/popular_jewellers/shri_hari_logo_sq.png', productCount: 180, rating: 4.7 },
            { id: '3', name: 'Cartier', location: 'Delhi, NCR', logoUrl: 'assets/images/popular_jewellers/cartier_logo.png', productCount: 320, rating: 4.9 },
            { id: '4', name: 'Anita Dongre Jewellery', location: 'Bangalore, Karnataka', logoUrl: 'assets/images/popular_jewellers/anita_dongre.png', productCount: 150, rating: 4.6 },
            { id: '5', name: 'OP Jewellers', location: 'Pune, Maharashtra', logoUrl: 'assets/images/popular_jewellers/OP.png', productCount: 200, rating: 4.5 },
            { id: '6', name: 'Local Jeweller', location: 'Chennai, Tamil Nadu', logoUrl: 'assets/images/popular_jewellers/Frame 2043683274.png', productCount: 120, rating: 4.4 },
            { id: '7', name: 'Kalyan Jewellers', location: 'Kochi, Kerala', logoUrl: 'assets/images/logo.png', productCount: 210, rating: 4.6 },
            { id: '8', name: 'Malabar Gold', location: 'Hyderabad, Telangana', logoUrl: 'assets/images/logo.png', productCount: 190, rating: 4.7 },
            { id: '9', name: 'Bhima Jewellers', location: 'Bangalore, Karnataka', logoUrl: 'assets/images/logo.png', productCount: 160, rating: 4.5 }
        ];

        try {
            // Show skeletons
            container.innerHTML = '';
            for (let i = 0; i < 6; i++) {
                container.appendChild(createShopCardSkeleton());
            }

            // Fetch shops
            const response = await fetch(`${CONFIG.API_BASE_URL}/api/shops`);

            if (!response.ok) {
                if (response.status === 404) {
                    // API might not exist yet
                    throw new Error('API not found');
                }
                throw new Error('Failed to fetch shops');
            }

            const data = await response.json();
            const shops = data.shops || data.data || [];

            const shopsToShow = shops.length > 0 ? shops : mockShops;

            container.innerHTML = '';
            shopsToShow.forEach(shop => {
                container.appendChild(createShopCard(shop));
            });

        } catch (error) {
            console.error('Error loading shops:', error);
            // Fallback to mock data
            container.innerHTML = '';
            mockShops.forEach(shop => {
                container.appendChild(createShopCard(shop));
            });
        }
    }

    /**
     * Initialize
     */
    function init() {
        console.log('🏪 Initializing shops page...');
        loadShops();
    }

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();
