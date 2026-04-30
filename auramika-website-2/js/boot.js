// ===================================
// BOOT SCREEN CONTROLLER
// Handles splash video playback
// ===================================

class BootScreen {
    constructor(options = {}) {
        this.options = {
            videoSrc: options.videoSrc || 'assets/videos/boot.mp4',
            minDuration: options.minDuration || 2000, // Minimum display time
            skipOnClick: options.skipOnClick !== false,
            ...options
        };

        this.bootElement = null;
        this.videoElement = null;
        this.startTime = Date.now();
        this.hasShown = this.checkIfShown();

        this.init();
    }

    checkIfShown() {
        // Check if boot screen was shown in this session
        return sessionStorage.getItem('bootScreenShown') === 'true';
    }

    init() {
        // Skip if already shown in this session
        if (this.hasShown) {
            return;
        }

        // Add boot-active class to body
        document.body.classList.add('boot-active');

        // Create boot screen HTML
        this.createBootScreen();

        // Load and play video
        this.loadVideo();

        // Add skip functionality
        if (this.options.skipOnClick) {
            this.bootElement.addEventListener('click', () => this.hide());
        }

        // Mark as shown
        sessionStorage.setItem('bootScreenShown', 'true');
    }

    createBootScreen() {
        const bootHTML = `
            <div class="boot-screen" id="bootScreen">
                <video class="boot-video" id="bootVideo" playsinline muted>
                    <source src="${this.options.videoSrc}" type="video/mp4">
                </video>
                <div class="boot-loader">
                    <div class="boot-spinner"></div>
                    <div class="boot-logo">Swarna Setu</div>
                </div>
            </div>
        `;

        document.body.insertAdjacentHTML('afterbegin', bootHTML);
        this.bootElement = document.getElementById('bootScreen');
        this.videoElement = document.getElementById('bootVideo');
    }

    loadVideo() {
        this.bootElement.classList.add('loading');

        this.videoElement.addEventListener('loadeddata', () => {
            this.bootElement.classList.remove('loading');
            this.playVideo();
        });

        this.videoElement.addEventListener('error', () => {
            console.error('Failed to load boot video');
            // Hide after minimum duration if video fails
            setTimeout(() => this.hide(), this.options.minDuration);
        });

        this.videoElement.addEventListener('ended', () => {
            this.hide();
        });

        // Start loading
        this.videoElement.load();
    }

    playVideo() {
        const playPromise = this.videoElement.play();

        if (playPromise !== undefined) {
            playPromise.catch(error => {
                console.error('Video autoplay failed:', error);
                // Hide after minimum duration if autoplay fails
                setTimeout(() => this.hide(), this.options.minDuration);
            });
        }
    }

    hide() {
        const elapsed = Date.now() - this.startTime;
        const remaining = Math.max(0, this.options.minDuration - elapsed);

        setTimeout(() => {
            this.bootElement.classList.add('hidden');
            document.body.classList.remove('boot-active');

            // Remove from DOM after transition
            setTimeout(() => {
                if (this.bootElement && this.bootElement.parentNode) {
                    this.bootElement.remove();
                }
            }, 500);
        }, remaining);
    }

    // Force show boot screen (useful for testing)
    static forceShow() {
        sessionStorage.removeItem('bootScreenShown');
        window.location.reload();
    }
}

// Initialize boot screen when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        new BootScreen({
            minDuration: 2000,
            skipOnClick: true
        });
    });
} else {
    new BootScreen({
        minDuration: 2000,
        skipOnClick: true
    });
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = BootScreen;
}
