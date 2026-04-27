// ===================================
// SWARNA SETU - PRODUCT DETAIL PAGE LOGIC
// Product display and interactions
// ===================================

(function () {
    'use strict';

    // Mock product data (consolidated from other files + extras)
    const mockProducts = [
        { id: '1', name: 'Elegant Gold Pendant', vendorName: 'Tanishq', price: 45000, imageUrl: 'assets/images/Pendant1.jpg', purity: '22K', weightInGrams: 8.5, metal: 'Gold', category: 'pendants', description: 'A stunning gold pendant featuring intricate craftsmanship. Perfect for special occasions and daily wear alike.' },
        { id: '2', name: 'Diamond Earrings', vendorName: 'Bluestone', price: 32000, imageUrl: 'assets/images/earring1.jpg', purity: '18K', weightInGrams: 6.2, metal: 'Gold', category: 'earrings', description: 'Sparkling diamond earrings set in 18K gold. These earrings add a touch of glamour to any outfit.' },
        { id: '3', name: 'Gold Ring', vendorName: 'Giva', price: 28000, imageUrl: 'assets/images/gold_ring.jpg', purity: '22K', weightInGrams: 5.8, metal: 'Gold', category: 'rings', description: 'A classic gold ring design that symbolizes eternity and love. Crafted with precision.' },
        { id: '4', name: 'Starry Elegance Anklet', vendorName: 'Shri Hari', price: 18000, imageUrl: 'assets/images/Starry Elegance Gold Anklet1.jpg', purity: '18K', weightInGrams: 4.2, metal: 'Gold', category: 'anklets', description: 'Delicate gold anklet with star motifs. A charming accessory for your feet.' },
        { id: '5', name: 'Maang Tikka', vendorName: 'Anita Dongre', price: 22000, imageUrl: 'assets/images/Maang Tikka1.jpg', purity: '22K', weightInGrams: 3.5, metal: 'Gold', category: 'accessories', description: 'Traditional Maang Tikka with a modern twist. Perfect for weddings and festive celebrations.' },
        { id: '6', name: 'Gold Nose Pin', vendorName: 'Cartier', price: 8500, imageUrl: 'assets/images/gold Nose Pin1.jpg', purity: '18K', weightInGrams: 1.2, metal: 'Gold', category: 'accessories', description: 'A subtle yet elegant gold nose pin. Adds a hint of sparkle to your face.' },
        { id: '7', name: 'Teardrop Diamond Pendant', vendorName: 'Tanishq', price: 55000, imageUrl: 'assets/images/Teardrop Shaped Yellow Gold and Diamond Pendant1.jpg', purity: '18K', weightInGrams: 7.8, metal: 'Gold', category: 'pendants', description: 'Exquisite teardrop-shaped pendant encrusted with diamonds. A true masterpiece.' },
        { id: '8', name: 'Guardian Edge Pendant', vendorName: 'OP Jewellers', price: 42000, imageUrl: 'assets/images/Guardian Edge Diamond Pendant For Men1.jpg', purity: '18K', weightInGrams: 9.2, metal: 'Gold', category: 'pendants', description: 'Bold and masculine diamond pendant design. Makes a strong statement.' },
        { id: '9', name: 'Indriya Necklace', vendorName: 'Indriya', price: 85000, imageUrl: 'assets/images/top_selling/indriya_necklace.jpg', purity: '22K', weightInGrams: 15.5, metal: 'Gold', category: 'necklaces', description: 'Luxurious heavy gold necklace with intricate traditional patterns.' },
        { id: '10', name: 'Giva Gold Chain', vendorName: 'Giva', price: 38000, imageUrl: 'assets/images/top_selling/giva_gold_chain.jpg', purity: '18K', weightInGrams: 8.2, metal: 'Gold', category: 'chains', description: 'Sleek and durable gold chain. Can be worn alone or with a pendant.' },
        { id: '11', name: 'Bluestone Silver Chain', vendorName: 'Bluestone', price: 12000, imageUrl: 'assets/images/top_selling/bluestone_silver_chain.jpg', purity: '925', weightInGrams: 10.5, metal: 'Silver', category: 'chains', description: 'Premium sterling silver chain. A versatile accessory.' },
        { id: '12', name: 'Kids Pendant', vendorName: 'Bluestone', price: 15000, imageUrl: 'assets/images/top_selling/bluestone_kids_pendant.jpg', purity: '18K', weightInGrams: 3.8, metal: 'Gold', category: 'pendants', description: 'Adorable pendant designed specifically for children. Safe and stylish.' },
        { id: '13', name: 'Tanishq Kids Earrings', vendorName: 'Tanishq', price: 18000, imageUrl: 'assets/images/top_selling/tanishq_kids_earrings.jpg', purity: '18K', weightInGrams: 4.5, metal: 'Gold', category: 'earrings', description: 'Cute and comfortable earrings for kids.' },
        { id: '14', name: 'Giva Ring', vendorName: 'Giva', price: 25000, imageUrl: 'assets/images/top_selling/giva_ring.png', purity: '18K', weightInGrams: 5.2, metal: 'Gold', category: 'rings', description: 'Contemporary ring design suitable for everyday wear.' }
    ];

    /**
     * Get product ID from URL
     */
    function getProductId() {
        const params = new URLSearchParams(window.location.search);
        return params.get('id');
    }

    /**
     * Load product details
     */
    async function loadProductDetails() {
        const productId = getProductId();
        const container = document.getElementById('productDetailContainer');

        if (!productId || !container) return;

        try {
            // Find product in mock data first
            let product = mockProducts.find(p => p.id === productId || p.id === 'prod' + productId.replace('prod', ''));

            // Fallback to API if not found (simulated)
            if (!product) {
                // In real app: const response = await fetch(`${CONFIG.API_BASE_URL}/api/products/${productId}`);
                // Use a random mock product if specific ID not found, just for demo stability
                product = mockProducts[0];
                console.warn(`Product ${productId} not found, showing demo product`);
            }

            renderProductDetails(product);
            loadRelatedProducts(product.category);

            // Update page title
            document.title = `${product.name} | Swarna Setu`;

        } catch (error) {
            console.error('Error loading product details:', error);
            container.innerHTML = '<p>Error loading product details.</p>';
        }
    }

    /**
     * Render product details
     */
    function renderProductDetails(product) {
        const container = document.getElementById('productDetailContainer');
        const isWishlisted = State.isInWishlist(product.id);

        container.innerHTML = `
            <div class="product-gallery">
                <img src="${product.imageUrl}" alt="${product.name}" class="main-image shadow-md" onerror="this.src='${Utils.getPlaceholderImage(600, 600)}'">
            </div>
            
            <div class="product-info">
                <div class="product-vendor">${product.vendorName}</div>
                <h1 class="product-title">${product.name}</h1>
                <div class="product-price">${Utils.formatCurrency(product.price)}</div>
                
                <div class="product-description">
                    <p>${product.description || 'No description available.'}</p>
                </div>
                
                <div class="product-specs">
                    <div class="spec-item">
                        <span class="spec-label">Metal</span>
                        <span class="spec-value">${product.metal || 'Gold'}</span>
                    </div>
                    <div class="spec-item">
                        <span class="spec-label">Purity</span>
                        <span class="spec-value">${product.purity || '22K'}</span>
                    </div>
                    <div class="spec-item">
                        <span class="spec-label">Weight</span>
                        <span class="spec-value">${product.weightInGrams ? product.weightInGrams + ' g' : 'N/A'}</span>
                    </div>
                    <div class="spec-item">
                        <span class="spec-label">Vendor</span>
                        <span class="spec-value">${product.vendorName}</span>
                    </div>
                </div>
                
                <div class="action-buttons">
                    <button class="btn btn-primary btn-lg" style="flex: 1;" id="addToCartBtn">
                        Add to Bag
                    </button>
                    <button class="btn btn-outline btn-wishlist ${isWishlisted ? 'active' : ''}" id="wishlistBtn" aria-label="Add to Wishlist">
                        ${isWishlisted ? '❤️' : '🤍'}
                    </button>
                </div>
            </div>
        `;

        // Add event listeners
        document.getElementById('addToCartBtn').addEventListener('click', () => {
            State.addToCart(product);
        });

        document.getElementById('wishlistBtn').addEventListener('click', function () {
            const isNowWishlisted = State.toggleWishlist(product);
            this.textContent = isNowWishlisted ? '❤️' : '🤍';
            this.classList.toggle('active', isNowWishlisted);
        });
    }

    /**
     * Load related products
     */
    function loadRelatedProducts(category) {
        const container = document.getElementById('relatedProducts');
        if (!container) return;

        // Filter products generally related (same category or similar)
        let related = mockProducts.filter(p => p.category === category && p.id !== getProductId());

        // If not enough related products, just add some random ones
        if (related.length < 4) {
            const others = mockProducts.filter(p => p.category !== category);
            related = [...related, ...others].slice(0, 4);
        } else {
            related = related.slice(0, 4);
        }

        container.innerHTML = '';
        related.forEach(product => {
            container.appendChild(createProductCard(product));
        });
    }

    /**
     * Initialize
     */
    function init() {
        console.log('💎 Initializing product detail page...');
        loadProductDetails();
    }

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();
