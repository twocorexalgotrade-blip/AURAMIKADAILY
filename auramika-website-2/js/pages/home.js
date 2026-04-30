// ===================================
// SWARNA SETU - HOME PAGE LOGIC
// Homepage data loading and interactions
// ===================================

(function () {
    'use strict';

    // Categories data with real icons
    const categories = [
        { id: 'rings', name: 'Rings', icon: 'assets/images/ornament_section/rings.png' },
        { id: 'necklaces', name: 'Necklaces', icon: 'assets/images/ornament_section/neckless.png' },
        { id: 'earrings', name: 'Earrings', icon: 'assets/images/ornament_section/earings.png' },
        { id: 'bangles', name: 'Bangles', icon: 'assets/images/ornament_section/bangles.png' },
        { id: 'chains', name: 'Chains', icon: 'assets/images/ornament_section/chains.png' },
        { id: 'pendants', name: 'Pendants', icon: 'assets/images/ornament_section/pendents.png' },
        { id: 'bracelets', name: 'Bracelets', icon: 'assets/images/ornament_section/bracelets.png' },
        { id: 'anklets', name: 'Anklets', icon: 'assets/images/ornament_section/anklets.jpg' }
    ];

    // Iconic collections data
    const iconicCollections = [
        { id: 'anita_dongre', name: 'Anita Dongre', count: 45, image: 'assets/images/new_iconic_collections/anita_dongre.jpg' },
        { id: 'glamira', name: 'Glamira', count: 38, image: 'assets/images/new_iconic_collections/glamira.jpg' },
        { id: 'renu_oberoi', name: 'Renu Oberoi', count: 52, image: 'assets/images/new_iconic_collections/renu_oberoi.jpg' },
        { id: 'kalyan_kids', name: 'Kalyan Kids', count: 41, image: 'assets/images/new_iconic_collections/kalyan_kids.jpg' }
    ];

    /**
     * Render categories
     */
    function renderCategories() {
        const container = document.getElementById('categoryGrid');
        if (!container) return;

        container.innerHTML = '';

        categories.forEach(category => {
            const categoryItem = document.createElement('a');
            categoryItem.href = `products.html?category=${category.id}`;
            categoryItem.className = 'category-item';
            categoryItem.innerHTML = `
        <div class="category-icon">
          <img src="${category.icon}" alt="${category.name}" class="category-icon-image" onerror="this.style.display='none'">
        </div>
        <span class="category-name">${category.name}</span>
      `;
            container.appendChild(categoryItem);
        });
    }

    /**
     * Render iconic collections
     */
    function renderIconicCollections() {
        const container = document.getElementById('iconicCollections');
        if (!container) return;

        container.innerHTML = '';

        iconicCollections.forEach(collection => {
            const collectionCard = document.createElement('a');
            collectionCard.href = `products.html?collection=${collection.id}`;
            collectionCard.className = 'collection-card';
            collectionCard.innerHTML = `
        <img src="${collection.image}" alt="${collection.name}" class="collection-card-image" onerror="this.src='${Utils.getPlaceholderImage(280, 160)}'">
        <div class="collection-card-overlay">
          <h3 class="collection-card-title">${collection.name}</h3>
          <p class="collection-card-count">${collection.count} Products</p>
        </div>
      `;
            container.appendChild(collectionCard);
        });
    }

    /**
     * Load new arrivals
     */
    async function loadNewArrivals() {
        const container = document.getElementById('newArrivals');
        if (!container) return;

        // Mock product data with real images
        const mockProducts = [
            {
                id: 'prod1',
                name: 'Elegant Gold Pendant',
                vendorName: 'Tanishq',
                price: 45000,
                imageUrl: 'assets/images/Pendant1.jpg',
                purity: '22K',
                weightInGrams: 8.5,
                metal: 'Gold',
                badge: 'New'
            },
            {
                id: 'prod2',
                name: 'Diamond Earrings',
                vendorName: 'Bluestone',
                price: 32000,
                imageUrl: 'assets/images/earring1.jpg',
                purity: '18K',
                weightInGrams: 6.2,
                metal: 'Gold',
                badge: 'New'
            },
            {
                id: 'prod3',
                name: 'Gold Ring',
                vendorName: 'Giva',
                price: 28000,
                imageUrl: 'assets/images/gold_ring.jpg',
                purity: '22K',
                weightInGrams: 5.8,
                metal: 'Gold'
            },
            {
                id: 'prod4',
                name: 'Starry Elegance Anklet',
                vendorName: 'Shri Hari',
                price: 18000,
                imageUrl: 'assets/images/Starry Elegance Gold Anklet1.jpg',
                purity: '18K',
                weightInGrams: 4.2,
                metal: 'Gold'
            },
            {
                id: 'prod5',
                name: 'Maang Tikka',
                vendorName: 'Anita Dongre',
                price: 22000,
                imageUrl: 'assets/images/Maang Tikka1.jpg',
                purity: '22K',
                weightInGrams: 3.5,
                metal: 'Gold',
                badge: 'New'
            },
            {
                id: 'prod6',
                name: 'Gold Nose Pin',
                vendorName: 'Cartier',
                price: 8500,
                imageUrl: 'assets/images/gold Nose Pin1.jpg',
                purity: '18K',
                weightInGrams: 1.2,
                metal: 'Gold'
            },
            {
                id: 'prod7',
                name: 'Teardrop Diamond Pendant',
                vendorName: 'Tanishq',
                price: 55000,
                imageUrl: 'assets/images/Teardrop Shaped Yellow Gold and Diamond Pendant1.jpg',
                purity: '18K',
                weightInGrams: 7.8,
                metal: 'Gold'
            },
            {
                id: 'prod8',
                name: 'Guardian Edge Pendant',
                vendorName: 'OP Jewellers',
                price: 42000,
                imageUrl: 'assets/images/Guardian Edge Diamond Pendant For Men1.jpg',
                purity: '18K',
                weightInGrams: 9.2,
                metal: 'Gold'
            }
        ];

        try {
            showProductSkeletons(container, 4);

            const response = await fetch(`${CONFIG.API_BASE_URL}/api/products?sort=newest&limit=8`);

            if (!response.ok) {
                throw new Error('Failed to fetch products');
            }

            const data = await response.json();
            const products = data.products || data.data || [];

            // Use API data if available, otherwise use mock data
            renderProducts(products.length > 0 ? products : mockProducts, container);
        } catch (error) {
            console.error('Error loading new arrivals:', error);
            // Use mock data as fallback
            renderProducts(mockProducts, container);
        }
    }

    /**
     * Load top selling products
     */
    async function loadTopSelling() {
        const container = document.getElementById('topSelling');
        if (!container) return;

        // Mock top selling products
        const mockTopSelling = [
            {
                id: 'top1',
                name: 'Indriya Necklace',
                vendorName: 'Indriya',
                price: 85000,
                imageUrl: 'assets/images/top_selling/indriya_necklace.jpg',
                purity: '22K',
                weightInGrams: 15.5,
                metal: 'Gold',
                badge: 'Bestseller'
            },
            {
                id: 'top2',
                name: 'Giva Gold Chain',
                vendorName: 'Giva',
                price: 38000,
                imageUrl: 'assets/images/top_selling/giva_gold_chain.jpg',
                purity: '18K',
                weightInGrams: 8.2,
                metal: 'Gold',
                badge: 'Bestseller'
            },
            {
                id: 'top3',
                name: 'Bluestone Silver Chain',
                vendorName: 'Bluestone',
                price: 12000,
                imageUrl: 'assets/images/top_selling/bluestone_silver_chain.jpg',
                purity: '925',
                weightInGrams: 10.5,
                metal: 'Silver'
            },
            {
                id: 'top4',
                name: 'Kids Pendant',
                vendorName: 'Bluestone',
                price: 15000,
                imageUrl: 'assets/images/top_selling/bluestone_kids_pendant.jpg',
                purity: '18K',
                weightInGrams: 3.8,
                metal: 'Gold'
            },
            {
                id: 'top5',
                name: 'Tanishq Kids Earrings',
                vendorName: 'Tanishq',
                price: 18000,
                imageUrl: 'assets/images/top_selling/tanishq_kids_earrings.jpg',
                purity: '18K',
                weightInGrams: 4.5,
                metal: 'Gold'
            },
            {
                id: 'top6',
                name: 'Giva Ring',
                vendorName: 'Giva',
                price: 25000,
                imageUrl: 'assets/images/top_selling/giva_ring.png',
                purity: '18K',
                weightInGrams: 5.2,
                metal: 'Gold'
            }
        ];

        try {
            container.innerHTML = '';
            for (let i = 0; i < 4; i++) {
                container.appendChild(createProductCardSkeleton());
            }

            const response = await fetch(`${CONFIG.API_BASE_URL}/api/products?sort=popular&limit=8`);

            if (!response.ok) {
                throw new Error('Failed to fetch products');
            }

            const data = await response.json();
            const products = data.products || data.data || [];

            container.innerHTML = '';
            const productsToShow = products.length > 0 ? products : mockTopSelling;
            productsToShow.forEach(product => {
                container.appendChild(createProductCard(product));
            });
        } catch (error) {
            console.error('Error loading top selling:', error);
            // Use mock data as fallback
            container.innerHTML = '';
            mockTopSelling.forEach(product => {
                container.appendChild(createProductCard(product));
            });
        }
    }

    /**
     * Load featured shops
     */
    async function loadFeaturedShops() {
        const container = document.getElementById('featuredShops');
        if (!container) return;

        // Mock shop data with real logos
        const mockShops = [
            {
                id: 'tanishq',
                name: 'Tanishq',
                location: 'Mumbai, Maharashtra',
                logoUrl: 'assets/images/popular_jewellers/tanishq_logo.png',
                productCount: 250,
                rating: 4.8
            },
            {
                id: 'shri_hari',
                name: 'Shri Hari Jewellers',
                location: 'Surat, Gujarat',
                logoUrl: 'assets/images/popular_jewellers/shri_hari_logo_sq.png',
                productCount: 180,
                rating: 4.7
            },
            {
                id: 'cartier',
                name: 'Cartier',
                location: 'Delhi, NCR',
                logoUrl: 'assets/images/popular_jewellers/cartier_logo.png',
                productCount: 320,
                rating: 4.9
            },
            {
                id: 'anita_dongre',
                name: 'Anita Dongre Jewellery',
                location: 'Bangalore, Karnataka',
                logoUrl: 'assets/images/popular_jewellers/anita_dongre.png',
                productCount: 150,
                rating: 4.6
            },
            {
                id: 'op_jewellers',
                name: 'OP Jewellers',
                location: 'Pune, Maharashtra',
                logoUrl: 'assets/images/popular_jewellers/OP.png',
                productCount: 200,
                rating: 4.5
            },
            {
                id: 'local_jeweller',
                name: 'Local Jeweller',
                location: 'Chennai, Tamil Nadu',
                logoUrl: 'assets/images/popular_jewellers/Frame 2043683274.png',
                productCount: 120,
                rating: 4.4
            }
        ];

        try {
            showShopSkeletons(container, 3);

            const response = await fetch(`${CONFIG.API_BASE_URL}/api/shops?featured=true&limit=6`);

            if (!response.ok) {
                throw new Error('Failed to fetch shops');
            }

            const data = await response.json();
            const shops = data.shops || data.data || [];

            // Use API data if available, otherwise use mock data
            renderShops(shops.length > 0 ? shops : mockShops, container);
        } catch (error) {
            console.error('Error loading featured shops:', error);
            // Use mock data as fallback
            renderShops(mockShops, container);
        }
    }

    /**
     * Setup gender tabs
     */
    function setupGenderTabs() {
        const genderTabs = document.getElementById('genderTabs');
        if (!genderTabs) return;

        genderTabs.addEventListener('click', (e) => {
            const tab = e.target.closest('[data-gender]');
            if (!tab) return;

            const gender = tab.dataset.gender;

            // Update active state
            genderTabs.querySelectorAll('.chip').forEach(chip => {
                chip.classList.remove('active');
            });
            tab.classList.add('active');

            // Update state
            State.updateFilters({ gender });

            // Reload products with filter
            // For now, just show a toast
            Utils.showToast(`Showing ${gender === 'all' ? 'all' : gender + "'s"} jewelry`, 'info');
        });
    }

    /**
     * Setup material filter
     */
    function setupMaterialFilter() {
        const materialFilter = document.getElementById('materialFilter');
        if (!materialFilter) return;

        materialFilter.addEventListener('click', (e) => {
            const chip = e.target.closest('[data-material]');
            if (!chip) return;

            const material = chip.dataset.material;

            // Update active state
            materialFilter.querySelectorAll('.chip').forEach(c => {
                c.classList.remove('active');
            });
            chip.classList.add('active');

            // Update state
            State.updateFilters({ material });

            // Reload products with filter
            Utils.showToast(`Showing ${material === 'all' ? 'all' : material} jewelry`, 'info');
        });
    }

    /**
     * Load placeholder images
     */
    function loadPlaceholderImages() {
        // Hero image - use a beautiful gold ring
        const heroImage = document.getElementById('heroImage');
        if (heroImage && !heroImage.src) {
            heroImage.src = 'assets/images/gold_ring.jpg';
            heroImage.onerror = function () {
                this.src = 'assets/images/Pendant1.jpg';
            };
        }

        // Custom order image - use storefront background
        const customOrderImage = document.getElementById('customOrderImage');
        if (customOrderImage && !customOrderImage.src) {
            customOrderImage.src = 'assets/images/storefront_bg.png';
            customOrderImage.onerror = function () {
                this.src = 'assets/images/earring1.jpg';
            };
        }

        // Logo
        const headerLogo = document.getElementById('headerLogo');
        if (headerLogo && !headerLogo.src) {
            headerLogo.src = 'assets/images/logo.png';
            headerLogo.onerror = function () {
                this.style.display = 'none';
            };
        }
    }

    /**
     * Initialize home page
     */
    function init() {
        console.log('🏠 Initializing home page...');

        // Render static content
        renderCategories();
        renderIconicCollections();
        loadPlaceholderImages();

        // Setup interactions
        setupGenderTabs();
        setupMaterialFilter();

        // Load dynamic content
        loadNewArrivals();
        loadTopSelling();
        loadFeaturedShops();

        console.log('✅ Home page initialized');
    }

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();
