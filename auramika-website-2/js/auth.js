// ===================================
// SWARNA SETU - AUTHENTICATION
// Firebase authentication logic
// ===================================

const Auth = {
    // Current user
    currentUser: null,

    // Initialize auth
    init() {
        this.currentUser = Storage.getUser();

        // Listen for auth state changes
        if (typeof firebase !== 'undefined') {
            firebase.auth().onAuthStateChanged((user) => {
                if (user) {
                    console.log('User signed in:', user.phoneNumber);
                } else {
                    console.log('User signed out');
                }
            });
        }
    },

    // Get current user
    getCurrentUser() {
        return this.currentUser || Storage.getUser();
    },

    // Check if authenticated
    isAuthenticated() {
        return !!this.getCurrentUser();
    },

    // Logout
    async logout() {
        try {
            if (typeof firebase !== 'undefined') {
                await firebase.auth().signOut();
            }
            Storage.removeUser();
            Storage.removeToken();
            this.currentUser = null;
            window.location.href = 'auth.html';
        } catch (error) {
            console.error('Error logging out:', error);
            throw error;
        }
    },

    // Require authentication
    requireAuth() {
        if (!this.isAuthenticated()) {
            window.location.href = 'auth.html';
            return false;
        }
        return true;
    }
};

// Initialize on load
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => Auth.init());
} else {
    Auth.init();
}
