// ===================================
// SWARNA SETU - STATE MANAGEMENT
// Global state for cart, wishlist, and user
// ===================================

const State = {
    // User state
    user: null,
    isAuthenticated: false,

    // Cart state
    cart: [],
    cartCount: 0,
    cartTotal: 0,

    // Wishlist state
    wishlist: [],
    wishlistCount: 0,

    // Filters state
    filters: {
        gender: 'all',
        material: 'all',
        category: null,
        priceRange: null,
        sortBy: 'newest'
    },

    // Subscribers for state changes
    subscribers: {
        user: [],
        cart: [],
        wishlist: [],
        filters: []
    },

    /**
     * Initialize state from localStorage
     */
    init() {
        this.loadUser();
        this.loadCart();
        this.loadWishlist();
        this.updateUI();
    },

    /**
     * Subscribe to state changes
     * @param {string} key - State key to subscribe to
     * @param {Function} callback - Callback function
     */
    subscribe(key, callback) {
        if (this.subscribers[key]) {
            this.subscribers[key].push(callback);
        }
    },

    /**
     * Notify subscribers of state changes
     * @param {string} key - State key that changed
     */
    notify(key) {
        if (this.subscribers[key]) {
            this.subscribers[key].forEach(callback => callback(this[key]));
        }
        this.updateUI();
    },

    /**
     * Load user from localStorage
     */
    loadUser() {
        const token = Utils.storage.get(CONFIG.STORAGE_KEYS.TOKEN);
        const user = Utils.storage.get(CONFIG.STORAGE_KEYS.USER);

        if (token && user) {
            this.user = user;
            this.isAuthenticated = true;
            this.notify('user');
        }
    },

    /**
     * Set user
     * @param {Object} user - User object
     * @param {string} token - Auth token
     */
    setUser(user, token) {
        this.user = user;
        this.isAuthenticated = true;
        Utils.storage.set(CONFIG.STORAGE_KEYS.USER, user);
        Utils.storage.set(CONFIG.STORAGE_KEYS.TOKEN, token);
        this.notify('user');
    },

    /**
     * Clear user (logout)
     */
    clearUser() {
        this.user = null;
        this.isAuthenticated = false;
        Utils.storage.remove(CONFIG.STORAGE_KEYS.USER);
        Utils.storage.remove(CONFIG.STORAGE_KEYS.TOKEN);
        this.notify('user');
    },

    /**
     * Load cart from localStorage
     */
    loadCart() {
        const cart = Utils.storage.get(CONFIG.STORAGE_KEYS.CART) || [];
        this.cart = cart;
        this.calculateCartTotals();
        this.notify('cart');
    },

    /**
     * Add item to cart
     * @param {Object} product - Product to add
     * @param {number} quantity - Quantity to add
     */
    addToCart(product, quantity = 1) {
        const existingItem = this.cart.find(item => item.id === product.id);

        if (existingItem) {
            existingItem.quantity += quantity;
        } else {
            this.cart.push({
                ...product,
                quantity,
                addedAt: new Date().toISOString()
            });
        }

        this.saveCart();
        Utils.showToast('Added to cart', 'success');
    },

    /**
     * Remove item from cart
     * @param {string} productId - Product ID to remove
     */
    removeFromCart(productId) {
        this.cart = this.cart.filter(item => item.id !== productId);
        this.saveCart();
        Utils.showToast('Removed from cart', 'info');
    },

    /**
     * Update cart item quantity
     * @param {string} productId - Product ID
     * @param {number} quantity - New quantity
     */
    updateCartQuantity(productId, quantity) {
        const item = this.cart.find(item => item.id === productId);
        if (item) {
            if (quantity <= 0) {
                this.removeFromCart(productId);
            } else {
                item.quantity = quantity;
                this.saveCart();
            }
        }
    },

    /**
     * Clear cart
     */
    clearCart() {
        this.cart = [];
        this.saveCart();
    },

    /**
     * Save cart to localStorage
     */
    saveCart() {
        Utils.storage.set(CONFIG.STORAGE_KEYS.CART, this.cart);
        this.calculateCartTotals();
        this.notify('cart');
    },

    /**
     * Calculate cart totals
     */
    calculateCartTotals() {
        this.cartCount = this.cart.reduce((sum, item) => sum + item.quantity, 0);
        this.cartTotal = this.cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    },

    /**
     * Load wishlist from localStorage
     */
    loadWishlist() {
        const wishlist = Utils.storage.get(CONFIG.STORAGE_KEYS.WISHLIST) || [];
        this.wishlist = wishlist;
        this.wishlistCount = wishlist.length;
        this.notify('wishlist');
    },

    /**
     * Add item to wishlist
     * @param {Object} product - Product to add
     */
    addToWishlist(product) {
        const exists = this.wishlist.some(item => item.id === product.id);

        if (!exists) {
            this.wishlist.push({
                ...product,
                addedAt: new Date().toISOString()
            });
            this.saveWishlist();
            Utils.showToast('Added to wishlist', 'success');
            return true;
        }
        return false;
    },

    /**
     * Remove item from wishlist
     * @param {string} productId - Product ID to remove
     */
    removeFromWishlist(productId) {
        this.wishlist = this.wishlist.filter(item => item.id !== productId);
        this.saveWishlist();
        Utils.showToast('Removed from wishlist', 'info');
    },

    /**
     * Toggle wishlist item
     * @param {Object} product - Product to toggle
     * @returns {boolean} Is now in wishlist
     */
    toggleWishlist(product) {
        const exists = this.wishlist.some(item => item.id === product.id);

        if (exists) {
            this.removeFromWishlist(product.id);
            return false;
        } else {
            this.addToWishlist(product);
            return true;
        }
    },

    /**
     * Check if product is in wishlist
     * @param {string} productId - Product ID
     * @returns {boolean} Is in wishlist
     */
    isInWishlist(productId) {
        return this.wishlist.some(item => item.id === productId);
    },

    /**
     * Save wishlist to localStorage
     */
    saveWishlist() {
        Utils.storage.set(CONFIG.STORAGE_KEYS.WISHLIST, this.wishlist);
        this.wishlistCount = this.wishlist.length;
        this.notify('wishlist');
    },

    /**
     * Clear wishlist
     */
    clearWishlist() {
        this.wishlist = [];
        this.saveWishlist();
    },

    /**
     * Update filters
     * @param {Object} newFilters - New filter values
     */
    updateFilters(newFilters) {
        this.filters = { ...this.filters, ...newFilters };
        this.notify('filters');
    },

    /**
     * Reset filters
     */
    resetFilters() {
        this.filters = {
            gender: 'all',
            material: 'all',
            category: null,
            priceRange: null,
            sortBy: 'newest'
        };
        this.notify('filters');
    },

    /**
     * Update UI elements with current state
     */
    updateUI() {
        // Update cart count badges
        const cartCountElements = document.querySelectorAll('#cartCount, #bottomCartCount');
        cartCountElements.forEach(el => {
            if (el) {
                el.textContent = this.cartCount;
                el.style.display = this.cartCount > 0 ? 'flex' : 'none';
            }
        });

        // Update wishlist count badges
        const wishlistCountElements = document.querySelectorAll('#wishlistCount, #bottomWishlistCount');
        wishlistCountElements.forEach(el => {
            if (el) {
                el.textContent = this.wishlistCount;
                el.style.display = this.wishlistCount > 0 ? 'flex' : 'none';
            }
        });

        // Update user-specific UI
        const profileLinks = document.querySelectorAll('[href="profile.html"]');
        profileLinks.forEach(link => {
            if (this.isAuthenticated && this.user) {
                link.setAttribute('aria-label', this.user.name || 'Profile');
            }
        });
    }
};

// Initialize state when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => State.init());
} else {
    State.init();
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = State;
}
