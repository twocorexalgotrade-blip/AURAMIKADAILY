// ===================================
// SWARNA SETU - SHOP DETAIL PAGE LOGIC
// Shop interactions and product display
// ===================================

(function () {
    'use strict';

    // Mock shop data
    const mockShops = [
        {
            id: '1',
            name: 'Tanishq',
            location: 'Mumbai, Maharashtra',
            logoUrl: 'assets/images/popular_jewellers/tanishq_logo.png',
            bannerUrl: 'assets/images/storefront_bg.png',
            rating: 4.8,
            productCount: 250,
            description: 'Tanishq is India’s largest and most trusted jewellery brand, known for its superior craftsmanship, exclusive designs, and guaranteed product quality.',
            address: '123, Linking Road, Bandra West, Mumbai - 400050',
            contact: '+91 22 1234 5678',
            timings: '10:00 AM - 9:00 PM (All Days)'
        },
        {
            id: '2',
            name: 'Kalyan Jewellers',
            location: 'Thrissur, Kerala',
            logoUrl: 'assets/images/popular_jewellers/kalyan_logo.png',
            rating: 4.7,
            productCount: 180,
            description: 'Kalyan Jewellers offers a wide array of traditional and contemporary jewellery designs in gold, diamonds, and precious stones.',
            address: 'Main Road, Thrissur, Kerala - 680001',
            contact: '+91 487 234 5678',
            timings: '9:30 AM - 8:30 PM'
        },
        {
            id: '3',
            name: 'Malabar Gold & Diamonds',
            location: 'Kozhikode, Kerala',
            logoUrl: 'assets/images/popular_jewellers/malabar_logo.png',
            rating: 4.9,
            productCount: 300,
            description: 'Experience the finest collection of gold, diamond, platinum, and precious stone jewellery at Malabar Gold & Diamonds.',
            address: 'Mavoor Road, Kozhikode, Kerala - 673001',
            contact: '+91 495 234 5678',
            timings: '10:00 AM - 9:00 PM'
        },
        {
            id: '4',
            name: 'PC Jeweller',
            location: 'New Delhi',
            logoUrl: 'assets/images/popular_jewellers/pc_logo.png',
            rating: 4.6,
            productCount: 150,
            description: 'PC Jeweller is a leading jewellery brand in India, known for its contemporary designs and hallmarked gold jewellery.',
            address: 'Karol Bagh, New Delhi - 110005',
            contact: '+91 11 2345 6789',
            timings: '10:30 AM - 8:30 PM'
        },
        {
            id: '5',
            name: 'Reliance Jewels',
            location: 'Mumbai',
            logoUrl: 'assets/images/popular_jewellers/reliance_logo.png',
            rating: 4.5,
            productCount: 120,
            description: 'Reliance Jewels offers a wide range of gold, diamond, and silver jewellery with a focus on quality and design.',
            address: 'Infinity Mall, Andheri West, Mumbai - 400053',
            contact: '+91 22 9876 5432',
            timings: '11:00 AM - 9:30 PM'
        }
    ];

    // Mock products for the shop
    const mockShopProducts = [
        { id: '1', name: 'Elegant Gold Pendant', price: 45000, imageUrl: 'assets/images/Pendant1.jpg', purity: '22K', weightInGrams: 8.5 },
        { id: '7', name: 'Teardrop Diamond Pendant', price: 55000, imageUrl: 'assets/images/Teardrop Shaped Yellow Gold and Diamond Pendant1.jpg', purity: '18K', weightInGrams: 7.8, badge: 'Best Seller' },
        { id: '13', name: 'Kids Earrings', price: 18000, imageUrl: 'assets/images/top_selling/tanishq_kids_earrings.jpg', purity: '18K', weightInGrams: 4.5 },
        { id: '25', name: 'Gold Bangle Set', price: 120000, imageUrl: 'assets/images/bangle1.jpg', purity: '22K', weightInGrams: 25.0, badge: 'New' },
        { id: '26', name: 'Wedding Necklace', price: 250000, imageUrl: 'assets/images/necklace1.jpg', purity: '22K', weightInGrams: 45.0 },
        { id: '27', name: 'Solitaire Ring', price: 65000, imageUrl: 'assets/images/ring1.jpg', purity: '18K', weightInGrams: 4.0 },
        { id: '28', name: 'Silver Anklets', price: 3500, imageUrl: 'assets/images/anklet1.jpg', purity: '925', weightInGrams: 15.0 },
        { id: '29', name: 'Diamond Nose Pin', price: 12000, imageUrl: 'assets/images/nosepin1.jpg', purity: '18K', weightInGrams: 1.5 }
    ];

    /**
     * Get shop ID from URL
     */
    function getShopId() {
        const params = new URLSearchParams(window.location.search);
        return params.get('id');
    }

    /**
     * Load shop details
     */
    async function loadShopDetails() {
        const shopId = getShopId();
        const container = document.getElementById('shopHeaderContainer');

        if (!shopId || !container) return;

        try {
            // Find shop in mock data
            let shop = mockShops.find(s => s.id === shopId);

            // Fallback (simulated API)
            if (!shop) {
                console.warn(`Shop ${shopId} not found, showing demo shop`);
                shop = mockShops[0];
            }

            renderShopHeader(shop, container);
            renderShopProducts(shop);

            document.title = `${shop.name} | Swarna Setu`;

        } catch (error) {
            console.error('Error loading shop details:', error);
            container.innerHTML = '<p class="text-center p-8">Error loading shop details.</p>';
        }
    }

    /**
     * Render shop header
     */
    function renderShopHeader(shop, container) {
        // Use shop banner if available, else default
        const bannerStyle = shop.bannerUrl ?
            `background-image: linear-gradient(rgba(0,0,0,0.6), rgba(0,0,0,0.6)), url('${shop.bannerUrl}');` : '';

        container.innerHTML = `
            <section class="shop-header-section" style="${bannerStyle}">
                <div class="container">
                    <div class="shop-logo-large">
                        <img src="${shop.logoUrl}" alt="${shop.name}" onerror="this.src='${Utils.getPlaceholderImage(150, 150)}'">
                    </div>
                    <h1 class="shop-title">${shop.name}</h1>
                    <div class="shop-meta">
                        <span>📍 ${shop.location}</span> • 
                        <span>⭐ ${shop.rating} Rating</span> • 
                        <span>💎 ${shop.productCount}+ Products</span>
                    </div>
                    
                    <p style="max-width: 700px; margin: 0 auto 24px; color: rgba(255,255,255,0.9); line-height: 1.6;">
                        ${shop.description}
                    </p>
                    
                    <div class="shop-contact-info" style="font-size: 0.9rem; opacity: 0.8;">
                        <p>📞 ${shop.contact} | 🕒 ${shop.timings}</p>
                        <p>${shop.address}</p>
                    </div>
                </div>
            </section>
        `;
    }

    /**
     * Render shop products
     */
    function renderShopProducts(shop) {
        const container = document.getElementById('shopProductsGrid');
        if (!container) return;

        // In a real app, we would fetch products by shop ID
        // const response = await fetch(`${CONFIG.API_BASE_URL}/api/products?shopId=${shop.id}`);
        // For now, allow all mock products but add vendor name

        const products = mockShopProducts.map(p => ({
            ...p,
            vendorName: shop.name
        }));

        container.innerHTML = '';

        if (products.length === 0) {
            container.innerHTML = '<p class="text-center col-span-full">No products found for this jeweller.</p>';
            return;
        }

        products.forEach(product => {
            const card = createProductCard(product);
            container.appendChild(card);
        });
    }

    /**
     * Initialize
     */
    function init() {
        console.log('🏪 Initializing shop detail page...');
        loadShopDetails();
    }

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();
