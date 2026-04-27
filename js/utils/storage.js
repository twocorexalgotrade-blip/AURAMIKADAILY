// ===================================
// SWARNA SETU - STORAGE UTILITIES
// LocalStorage management
// ===================================

const Storage = {
    // Get item from localStorage
    get(key) {
        try {
            const item = localStorage.getItem(key);
            return item ? JSON.parse(item) : null;
        } catch (error) {
            console.error(`Error getting ${key} from storage:`, error);
            return null;
        }
    },

    // Set item in localStorage
    set(key, value) {
        try {
            localStorage.setItem(key, JSON.stringify(value));
            return true;
        } catch (error) {
            console.error(`Error setting ${key} in storage:`, error);
            return false;
        }
    },

    // Remove item from localStorage
    remove(key) {
        try {
            localStorage.removeItem(key);
            return true;
        } catch (error) {
            console.error(`Error removing ${key} from storage:`, error);
            return false;
        }
    },

    // Clear all storage
    clear() {
        try {
            localStorage.clear();
            return true;
        } catch (error) {
            console.error('Error clearing storage:', error);
            return false;
        }
    },

    // User-specific methods
    getUser() {
        return this.get(CONFIG.STORAGE_KEYS.USER);
    },

    setUser(user) {
        return this.set(CONFIG.STORAGE_KEYS.USER, user);
    },

    removeUser() {
        return this.remove(CONFIG.STORAGE_KEYS.USER);
    },

    // Token methods
    getToken() {
        return this.get(CONFIG.STORAGE_KEYS.TOKEN);
    },

    setToken(token) {
        return this.set(CONFIG.STORAGE_KEYS.TOKEN, token);
    },

    removeToken() {
        return this.remove(CONFIG.STORAGE_KEYS.TOKEN);
    },

    // Cart methods
    getCart() {
        return this.get(CONFIG.STORAGE_KEYS.CART) || [];
    },

    setCart(cart) {
        return this.set(CONFIG.STORAGE_KEYS.CART, cart);
    },

    addToCart(item) {
        const cart = this.getCart();
        cart.push(item);
        return this.setCart(cart);
    },

    removeFromCart(itemId) {
        const cart = this.getCart();
        const filtered = cart.filter(item => item.id !== itemId);
        return this.setCart(filtered);
    },

    clearCart() {
        return this.setCart([]);
    },

    // Wishlist methods
    getWishlist() {
        return this.get(CONFIG.STORAGE_KEYS.WISHLIST) || [];
    },

    setWishlist(wishlist) {
        return this.set(CONFIG.STORAGE_KEYS.WISHLIST, wishlist);
    },

    addToWishlist(productId) {
        const wishlist = this.getWishlist();
        if (!wishlist.includes(productId)) {
            wishlist.push(productId);
            return this.setWishlist(wishlist);
        }
        return false;
    },

    removeFromWishlist(productId) {
        const wishlist = this.getWishlist();
        const filtered = wishlist.filter(id => id !== productId);
        return this.setWishlist(filtered);
    },

    isInWishlist(productId) {
        const wishlist = this.getWishlist();
        return wishlist.includes(productId);
    }
};
