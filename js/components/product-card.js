// ===================================
// SWARNA SETU - PRODUCT CARD COMPONENT
// Reusable product card component
// ===================================

/**
 * Create a product card element
 * @param {Object} product - Product data
 * @returns {HTMLElement} Product card element
 */
function createProductCard(product) {
  const card = document.createElement('div');
  card.className = 'product-card';
  card.dataset.productId = product.id;

  // Check if product is in wishlist
  const isWishlisted = State.isInWishlist(product.id);

  // Product image
  const imageUrl = product.imageUrl || product.image_url || Utils.getPlaceholderImage();

  card.innerHTML = `
    <div class="product-card-image">
      <img src="${imageUrl}" alt="${product.name}" loading="lazy" onerror="this.src='${Utils.getPlaceholderImage()}'">
      ${product.badge ? `<span class="product-card-badge">${product.badge}</span>` : ''}
      <button class="product-card-wishlist ${isWishlisted ? 'active' : ''}" data-product-id="${product.id}" aria-label="Add to wishlist">
        ${isWishlisted ? '❤️' : '🤍'}
      </button>
    </div>
    <div class="product-card-content">
      <div class="product-card-vendor">${product.vendorName || product.vendor_name || 'Swarna Setu'}</div>
      <h3 class="product-card-title">${product.name}</h3>
      <div class="product-card-price">${Utils.formatPrice(product.price)}</div>
      ${product.purity || product.weightInGrams || product.weight_in_grams ? `
        <div class="product-card-specs">
          ${product.purity ? `<span>${product.purity}</span>` : ''}
          ${product.weightInGrams || product.weight_in_grams ? `<span>${Utils.formatWeight(product.weightInGrams || product.weight_in_grams)}</span>` : ''}
        </div>
      ` : ''}
    </div>
  `;

  // Add click handler for card
  card.addEventListener('click', (e) => {
    // Don't navigate if clicking wishlist button
    if (e.target.closest('.product-card-wishlist')) {
      return;
    }
    window.location.href = `product-detail.html?id=${product.id}`;
  });

  // Add wishlist toggle handler
  const wishlistBtn = card.querySelector('.product-card-wishlist');
  wishlistBtn.addEventListener('click', (e) => {
    e.stopPropagation();
    const isNowWishlisted = State.toggleWishlist(product);
    wishlistBtn.classList.toggle('active', isNowWishlisted);
    wishlistBtn.textContent = isNowWishlisted ? '❤️' : '🤍';
  });

  return card;
}

/**
 * Create a skeleton product card for loading state
 * @returns {HTMLElement} Skeleton card element
 */
function createProductCardSkeleton() {
  const skeleton = document.createElement('div');
  skeleton.className = 'product-card';
  skeleton.innerHTML = `
    <div class="skeleton" style="width: 100%; padding-top: 100%;"></div>
    <div style="padding: 16px;">
      <div class="skeleton skeleton-text" style="width: 60%;"></div>
      <div class="skeleton skeleton-text" style="width: 90%; height: 1.5em; margin-top: 8px;"></div>
      <div class="skeleton skeleton-text" style="width: 40%; margin-top: 8px;"></div>
    </div>
  `;
  return skeleton;
}

/**
 * Render products to a container
 * @param {Array} products - Array of products
 * @param {HTMLElement} container - Container element
 * @param {boolean} append - Whether to append or replace
 */
function renderProducts(products, container, append = false) {
  if (!container) return;

  if (!append) {
    container.innerHTML = '';
  }

  if (!products || products.length === 0) {
    if (!append) {
      container.innerHTML = `
        <div style="grid-column: 1 / -1; text-align: center; padding: 60px 20px;">
          <div style="font-size: 48px; margin-bottom: 16px;">💎</div>
          <h3 style="font-family: var(--font-serif); font-size: 24px; margin-bottom: 8px;">No products found</h3>
          <p style="color: var(--color-gray);">Try adjusting your filters or search terms</p>
        </div>
      `;
    }
    return;
  }

  products.forEach(product => {
    const card = createProductCard(product);
    container.appendChild(card);
  });
}

/**
 * Show loading skeletons
 * @param {HTMLElement} container - Container element
 * @param {number} count - Number of skeletons to show
 */
function showProductSkeletons(container, count = 4) {
  if (!container) return;

  container.innerHTML = '';
  for (let i = 0; i < count; i++) {
    container.appendChild(createProductCardSkeleton());
  }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    createProductCard,
    createProductCardSkeleton,
    renderProducts,
    showProductSkeletons
  };
}
