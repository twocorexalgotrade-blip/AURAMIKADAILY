// ===================================
// SWARNA SETU - CONFIGURATION
// API and Firebase Configuration
// ===================================

const CONFIG = {
  // API Configuration
  API_BASE_URL: 'https://swarna-setu-api.onrender.com',
  SOCKET_URL: 'https://swarna-setu-api.onrender.com',
  
  // Firebase Configuration
  // TODO: Replace with actual Firebase config from Firebase Console
  firebase: {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_AUTH_DOMAIN",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_STORAGE_BUCKET",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    appId: "YOUR_APP_ID"
  },
  
  // WebRTC Configuration
  rtcConfiguration: {
    iceServers: [
      { urls: 'stun:stun.l.google.com:19302' },
      { urls: 'stun:stun1.l.google.com:19302' },
      { urls: 'stun:stun2.l.google.com:19302' }
    ]
  },
  
  // App Configuration
  APP_NAME: 'Swarna Setu',
  DEFAULT_LOCATION: 'Mumbai, India',
  ITEMS_PER_PAGE: 20,
  MAX_CART_ITEMS: 50,
  
  // Storage Keys
  STORAGE_KEYS: {
    USER: 'swarna_setu_user',
    TOKEN: 'swarna_setu_token',
    CART: 'swarna_setu_cart',
    WISHLIST: 'swarna_setu_wishlist',
    RECENT_SEARCHES: 'swarna_setu_recent_searches'
  }
};

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = CONFIG;
}
