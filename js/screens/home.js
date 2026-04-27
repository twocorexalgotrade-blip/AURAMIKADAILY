// ===================================
// HOME SCREEN LOGIC
// Main home page functionality
// ===================================

// State
let currentGender = 'all';
let currentMaterial = 'all';
let products = [];
let shops = [];

// Mock data (in production, this would come from API)
const mockProducts = [
    {
        id: 'p1',
        vendorName: 'Tanishq',
        name: 'Teardrop Diamond Pendant',
        price: 32000,
        imageUrl: 'assets/images/pendant1.jpg',
        metal: 'Diamond',
        category: 'pendants',
        gender: 'women',
        badge: 'New'
    },
    {
        id: 'p2',
        vendorName: 'BlueStone',
        name: 'Elegant Gold Leaf Pendant',
        price: 18000,
        imageUrl: 'assets/images/pendant2.jpg',
        metal: 'Gold',
        category: 'pendants',
        gender: 'women'
    },
    {
        id: 'p3',
        vendorName: 'Senco Gold',
        name: 'Starry Elegance Gold Anklet',
        price: 29500,
        imageUrl: 'assets/images/anklet1.jpg',
        metal: 'Gold',
        category: 'anklets',
        gender: 'women',
        badge: 'Trending'
    },
    {
        id: 'p4',
        vendorName: 'CaratLane',
        name: 'Guardian Edge Diamond Pendant',
        price: 85000,
        imageUrl: 'assets/images/pendant-men.jpg',
        metal: 'Diamond',
        category: 'pendants',
        gender: 'men'
    },
    {
        id: 'p5',
        vendorName: 'Malabar Gold',
        name: 'Guiding Star Gold Pendant',
        price: 58000,
        imageUrl: 'assets/images/pendant-gold.jpg',
        metal: 'Gold',
        category: 'pendants',
        gender: 'men',
        badge: 'Popular'
    },
    {
        id: 'p6',
        vendorName: 'Tanishq',
        name: 'Ethnic Gold Maang Tikka',
        price: 92000,
        imageUrl: 'assets/images/maang-tikka.jpg',
        metal: 'Gold',
        category: 'accessories',
        gender: 'women'
    }
];

const mockShops = [
    {
        id: 'shop1',
        shop_name: 'Shri Hari Jewels',
        distance: '2.1 km',
        rating: 4.8,
        isVerified: true,
        tags: ['Sponsored', 'Gold Specialist'],
        logo_url: 'assets/images/shop1-logo.jpg',
        banner_url: 'assets/images/shop1-banner.jpg'
    },
    {
        id: 'shop2',
        shop_name: 'Tanishq - Vashi',
        distance: '3.5 km',
        rating: 4.9,
        isVerified: true,
        tags: ['Top Rated'],
        logo_url: 'assets/images/shop2-logo.jpg',
        banner_url: 'assets/images/shop2-banner.jpg'
    },
    {
        id: 'shop3',
        shop_name: 'CaratLane',
        distance: '4.0 km',
        rating: 4.7,
        isVerified: true,
        tags: [],
        logo_url: 'assets/images/shop3-logo.jpg',
        banner_url: 'assets/images/shop3-banner.jpg'
    }
];

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    initializeHome();
});

async function initializeHome() {
    // Load data
    products = mockProducts; // In production: await API.products.getAll()
    shops = mockShops; // In production: await API.shops.getAll()

    // Setup event listeners
    setupGenderTabs();
    setupMaterialFilter();
    setupCategoryGrid();
    setupSearch();

    // Render sections
    renderIconicCollections();
    renderTopSelling();
    renderFeaturedShops();

    // Update bag count
    updateBagCount();
}

// Gender tabs
function setupGenderTabs() {
    const genderTabs = document.querySelectorAll('.gender-tab');

    genderTabs.forEach(tab => {
        tab.addEventListener('click', () => {
            genderTabs.forEach(t => t.classList.remove('active'));
            tab.classList.add('active');
            currentGender = tab.dataset.gender;

            // Re-render products
            renderIconicCollections();
            renderTopSelling();
        });
    });
}

// Material filter
function setupMaterialFilter() {
    const materialChips = document.querySelectorAll('.material-chip');

    materialChips.forEach(chip => {
        chip.addEventListener('click', () => {
            materialChips.forEach(c => c.classList.remove('active'));
            chip.classList.add('active');
            currentMaterial = chip.dataset.material;

            // Re-render products
            renderIconicCollections();
            renderTopSelling();
        });
    });
}

// Category grid
function setupCategoryGrid() {
    const categoryItems = document.querySelectorAll('.category-item');

    categoryItems.forEach(item => {
        item.addEventListener('click', () => {
            const category = item.dataset.category;
            window.location.href = `products.html?category=${category}`;
        });
    });
}

// Search
function setupSearch() {
    const searchInput = document.getElementById('searchInput');

    searchInput.addEventListener('input', Helpers.debounce((e) => {
        const query = e.target.value.trim();
        if (query.length > 2) {
            performSearch(query);
        }
    }, 300));

    searchInput.addEventListener('focus', () => {
        // Could show search suggestions here
    });
}

function performSearch(query) {
    // Navigate to search results page
    window.location.href = `search.html?q=${encodeURIComponent(query)}`;
}

// Filter products
function filterProducts(productList) {
    return productList.filter(product => {
        const genderMatch = currentGender === 'all' || product.gender === currentGender;
        const materialMatch = currentMaterial === 'all' || product.metal.toLowerCase() === currentMaterial.toLowerCase();
        return genderMatch && materialMatch;
    });
}

// Render iconic collections
function renderIconicCollections() {
    const container = document.getElementById('iconicCollections');
    const filtered = filterProducts(products).slice(0, 6);

    if (filtered.length === 0) {
        container.innerHTML = '<p class="text-center text-secondary p-lg">No products found</p>';
        return;
    }

    container.innerHTML = filtered.map(product => `
    <div class="product-card-wrapper">
      ${createProductCard(product)}
    </div>
  `).join('');
}

// Render top selling
function renderTopSelling() {
    const container = document.getElementById('topSelling');
    const filtered = filterProducts(products).slice(0, 6);

    if (filtered.length === 0) {
        container.innerHTML = '<p class="text-center text-secondary p-lg">No products found</p>';
        return;
    }

    container.innerHTML = filtered.map(product => `
    <div class="product-card-wrapper">
      ${createProductCard(product)}
    </div>
  `).join('');
}

// Render featured shops
function renderFeaturedShops() {
    const container = document.getElementById('featuredShops');

    if (shops.length === 0) {
        container.innerHTML = '<p class="text-center text-secondary p-lg">No shops found</p>';
        return;
    }

    container.innerHTML = shops.map(shop => createShopCard(shop)).join('');
}
