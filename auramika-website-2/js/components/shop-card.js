// ===================================
// SWARNA SETU - SHOP CARD COMPONENT
// Reusable shop/jeweller card component
// ===================================

/**
 * Create a shop card element
 * @param {Object} shop - Shop data
 * @returns {HTMLElement} Shop card element
 */
function createShopCard(shop) {
  const card = document.createElement('div');
  card.className = 'shop-card';
  card.dataset.shopId = shop.id || shop._id;

  // Shop logo/image
  const logoUrl = shop.logoUrl || shop.logo_url || shop.imageUrl || Utils.getPlaceholderImage(200, 200);

  // Shop stats
  const productCount = shop.productCount || shop.product_count || 0;
  const rating = shop.rating || 4.5;

  card.innerHTML = `
    <div class="shop-card-header">
      <div class="shop-card-logo">
        <img src="${logoUrl}" alt="${shop.name}" loading="lazy" onerror="this.src='${Utils.getPlaceholderImage(200, 200)}'">
      </div>
    </div>
    <div class="shop-card-body">
      <h3 class="shop-card-name">${shop.name}</h3>
      <div class="shop-card-location">
        📍 ${shop.location || shop.city || 'India'}
      </div>
      <div class="shop-card-stats">
        <div class="shop-card-stat">
          <div class="shop-card-stat-value">${productCount}</div>
          <div class="shop-card-stat-label">Products</div>
        </div>
        <div class="shop-card-stat">
          <div class="shop-card-stat-value">${rating.toFixed(1)}</div>
          <div class="shop-card-stat-label">Rating</div>
        </div>
      </div>
    </div>
  `;

  // Add click handler
  card.addEventListener('click', () => {
    window.location.href = `shop-detail.html?id=${shop.id || shop._id}`;
  });

  return card;
}

/**
 * Create a skeleton shop card for loading state
 * @returns {HTMLElement} Skeleton card element
 */
function createShopCardSkeleton() {
  const skeleton = document.createElement('div');
  skeleton.className = 'shop-card';
  skeleton.innerHTML = `
    <div class="shop-card-header">
      <div class="shop-card-logo">
        <div class="skeleton skeleton-circle" style="width: 100%; height: 100%;"></div>
      </div>
    </div>
    <div class="shop-card-body">
      <div class="skeleton skeleton-text" style="width: 70%; margin: 0 auto 8px;"></div>
      <div class="skeleton skeleton-text" style="width: 50%; margin: 0 auto 16px;"></div>
      <div style="padding-top: 16px; border-top: 1px solid var(--color-gray-lightest);">
        <div class="skeleton skeleton-text" style="width: 80%; margin: 0 auto;"></div>
      </div>
    </div>
  `;
  return skeleton;
}

/**
 * Render shops to a container
 * @param {Array} shops - Array of shops
 * @param {HTMLElement} container - Container element
 * @param {boolean} append - Whether to append or replace
 */
function renderShops(shops, container, append = false) {
  if (!container) return;

  if (!append) {
    container.innerHTML = '';
  }

  if (!shops || shops.length === 0) {
    if (!append) {
      container.innerHTML = `
        <div style="grid-column: 1 / -1; text-align: center; padding: 60px 20px;">
          <div style="font-size: 48px; margin-bottom: 16px;">🏪</div>
          <h3 style="font-family: var(--font-serif); font-size: 24px; margin-bottom: 8px;">No jewellers found</h3>
          <p style="color: var(--color-gray);">Try adjusting your search or location</p>
        </div>
      `;
    }
    return;
  }

  shops.forEach(shop => {
    const card = createShopCard(shop);
    container.appendChild(card);
  });
}

/**
 * Show loading skeletons
 * @param {HTMLElement} container - Container element
 * @param {number} count - Number of skeletons to show
 */
function showShopSkeletons(container, count = 3) {
  if (!container) return;

  container.innerHTML = '';
  for (let i = 0; i < count; i++) {
    container.appendChild(createShopCardSkeleton());
  }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    createShopCard,
    createShopCardSkeleton,
    renderShops,
    showShopSkeletons
  };
}
