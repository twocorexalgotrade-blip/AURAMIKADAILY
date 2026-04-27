// ===================================
// SWARNA SETU - API SERVICE
// Centralized API communication layer
// ===================================

const API = {
    // Base request method
    async request(endpoint, options = {}) {
        const url = `${CONFIG.API_BASE_URL}${endpoint}`;
        const token = Storage.getToken();

        const defaultOptions = {
            headers: {
                'Content-Type': 'application/json',
                ...(token && { 'Authorization': `Bearer ${token}` })
            }
        };

        const config = {
            ...defaultOptions,
            ...options,
            headers: {
                ...defaultOptions.headers,
                ...options.headers
            }
        };

        try {
            const response = await fetch(url, config);
            const data = await response.json();

            if (!response.ok) {
                throw new Error(data.message || 'API request failed');
            }

            return data;
        } catch (error) {
            console.error('API Error:', error);
            throw error;
        }
    },

    // GET request
    get(endpoint) {
        return this.request(endpoint, { method: 'GET' });
    },

    // POST request
    post(endpoint, body) {
        return this.request(endpoint, {
            method: 'POST',
            body: JSON.stringify(body)
        });
    },

    // PUT request
    put(endpoint, body) {
        return this.request(endpoint, {
            method: 'PUT',
            body: JSON.stringify(body)
        });
    },

    // DELETE request
    delete(endpoint) {
        return this.request(endpoint, { method: 'DELETE' });
    },

    // ===================================
    // AUTH ENDPOINTS
    // ===================================

    auth: {
        checkMobile(mobileNumber) {
            return API.post('/api/auth/check-mobile', { mobileNumber });
        },

        completeProfile(userData) {
            return API.post('/api/user/complete-profile', userData);
        }
    },

    // ===================================
    // PRODUCT ENDPOINTS
    // ===================================

    products: {
        getByVendor(vendorId, page = 1, limit = 20, category = null) {
            let endpoint = `/api/vendor/products/${vendorId}?page=${page}&limit=${limit}`;
            if (category) endpoint += `&category=${category}`;
            return API.get(endpoint);
        },

        getPublishedByVendor(vendorId, page = 1, limit = 20, category = null) {
            let endpoint = `/api/vendor/published-products/${vendorId}?page=${page}&limit=${limit}`;
            if (category) endpoint += `&category=${category}`;
            return API.get(endpoint);
        },

        getById(productId) {
            return API.get(`/api/products/${productId}`);
        }
    },

    // ===================================
    // SHOP ENDPOINTS
    // ===================================

    shops: {
        getAll(page = 1, limit = 20) {
            return API.get(`/api/shops?page=${page}&limit=${limit}`);
        },

        getById(shopId) {
            return API.get(`/api/shops/${shopId}`);
        },

        getByVendorId(vendorId) {
            return API.get(`/api/shops/vendor/${vendorId}`);
        }
    },

    // ===================================
    // BAG/CART ENDPOINTS
    // ===================================

    bag: {
        get(userId) {
            return API.get(`/api/bag/${userId}`);
        },

        add(item) {
            return API.post('/api/bag/add', item);
        },

        remove(itemId) {
            return API.delete(`/api/bag/remove/${itemId}`);
        },

        clear(userId) {
            return API.delete(`/api/bag/clear/${userId}`);
        }
    },

    // ===================================
    // ORDER ENDPOINTS
    // ===================================

    orders: {
        getByUser(userId) {
            return API.get(`/api/orders/${userId}`);
        },

        getById(orderId) {
            return API.get(`/api/orders/detail/${orderId}`);
        },

        create(orderData) {
            return API.post('/api/orders/create', orderData);
        },

        updateStatus(orderId, status) {
            return API.put(`/api/orders/${orderId}/status`, { status });
        }
    },

    // ===================================
    // ADDRESS ENDPOINTS
    // ===================================

    addresses: {
        getByUser(userId) {
            return API.get(`/api/addresses/${userId}`);
        },

        add(addressData) {
            return API.post('/api/addresses/add', addressData);
        },

        update(addressId, addressData) {
            return API.put(`/api/addresses/update/${addressId}`, addressData);
        },

        delete(addressId) {
            return API.delete(`/api/addresses/delete/${addressId}`);
        },

        setDefault(addressId, userId) {
            return API.put(`/api/addresses/set-default/${addressId}`, { userId });
        }
    },

    // ===================================
    // VIDEO CALL ENDPOINTS
    // ===================================

    calls: {
        initiate(callData) {
            return API.post('/api/call/initiate', callData);
        },

        updateStatus(roomId, status, duration = 0) {
            return API.put(`/api/call/${roomId}/status`, { status, duration });
        },

        getHistory(userId, userType) {
            return API.get(`/api/call/history/${userId}?userType=${userType}`);
        }
    },

    // ===================================
    // GOLD RATE ENDPOINT
    // ===================================

    goldRate: {
        getLive() {
            return API.get('/api/gold-rate/live');
        }
    },

    // ===================================
    // WISHLIST ENDPOINTS (if backend supports)
    // ===================================

    wishlist: {
        get(userId) {
            return API.get(`/api/wishlist/${userId}`);
        },

        add(userId, productId) {
            return API.post('/api/wishlist/add', { userId, productId });
        },

        remove(userId, productId) {
            return API.delete(`/api/wishlist/remove/${userId}/${productId}`);
        }
    }
};
