/**
 * 3D TILT EFFECT FOR CATEGORY CARDS
 * Using Vanilla Tilt.js for premium interactive 3D effect
 */

// Initialize 3D Tilt Effect on Category Cards
function init3DTiltEffect() {
    // Wait for category items to be loaded
    const observer = new MutationObserver((mutations, obs) => {
        const categoryItems = document.querySelectorAll('.category-item');

        if (categoryItems.length > 0) {
            categoryItems.forEach(item => {
                // Initialize Vanilla Tilt with premium settings
                VanillaTilt.init(item, {
                    max: 15,                    // Maximum tilt rotation (degrees)
                    speed: 400,                 // Speed of the enter/exit transition
                    glare: true,                // Enable glare effect
                    "max-glare": 0.3,          // Maximum glare opacity
                    scale: 1.05,                // Scale on hover
                    perspective: 1000,          // Transform perspective
                    transition: true,           // Set a transition on enter/exit
                    easing: "cubic-bezier(.03,.98,.52,.99)", // Easing on enter/exit
                    gyroscope: true,            // Enable gyroscope (for mobile)
                    gyroscopeMinAngleX: -45,   // Min angle for gyroscope
                    gyroscopeMaxAngleX: 45,    // Max angle for gyroscope
                    gyroscopeMinAngleY: -45,
                    gyroscopeMaxAngleY: 45
                });

                // Add custom event listeners for enhanced effects
                item.addEventListener('tiltChange', (e) => {
                    // You can add custom logic here when tilt changes
                    const { tiltX, tiltY, percentageX, percentageY } = e.detail;
                });
            });

            obs.disconnect(); // Stop observing once initialized
        }
    });

    // Start observing the category grid for changes
    const categoryGrid = document.getElementById('categoryGrid');
    if (categoryGrid) {
        observer.observe(categoryGrid, {
            childList: true,
            subtree: true
        });
    }
}

// Enhanced Category Icon Rendering with Real Images
function enhanceCategoryIcons() {
    const categoryMapping = {
        'rings': {
            name: 'Rings',
            icon: '💍',
            image: 'assets/images/ornament_section/rings.png',
            gradient: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)'
        },
        'necklaces': {
            name: 'Necklaces',
            icon: '📿',
            image: 'assets/images/ornament_section/necklaces.png',
            gradient: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)'
        },
        'earrings': {
            name: 'Earrings',
            icon: '👂',
            image: 'assets/images/ornament_section/earrings.png',
            gradient: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)'
        },
        'bangles': {
            name: 'Bangles',
            icon: '⭕',
            image: 'assets/images/ornament_section/bangles.png',
            gradient: 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)'
        },
        'chains': {
            name: 'Chains',
            icon: '🔗',
            image: 'assets/images/ornament_section/chains.png',
            gradient: 'linear-gradient(135deg, #fa709a 0%, #fee140 100%)'
        },
        'pendants': {
            name: 'Pendants',
            icon: '💎',
            image: 'assets/images/ornament_section/pendants.png',
            gradient: 'linear-gradient(135deg, #30cfd0 0%, #330867 100%)'
        },
        'bracelets': {
            name: 'Bracelets',
            icon: '✨',
            image: 'assets/images/ornament_section/bracelets.png',
            gradient: 'linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)'
        },
        'anklets': {
            name: 'Anklets',
            icon: '🦶',
            image: 'assets/images/ornament_section/anklets.png',
            gradient: 'linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%)'
        }
    };

    return categoryMapping;
}

// Add 3D depth effect with CSS
function add3DDepthStyles() {
    const style = document.createElement('style');
    style.textContent = `
        /* 3D Tilt Effect Enhancements */
        .category-item {
            transform-style: preserve-3d;
            will-change: transform;
            cursor: pointer;
        }
        
        .category-item .category-icon,
        .category-item .category-name {
            transform: translateZ(40px);
            transition: transform 0.3s ease;
        }
        
        .category-item:hover .category-icon {
            transform: translateZ(60px) scale(1.1);
        }
        
        .category-item:hover .category-name {
            transform: translateZ(50px);
        }
        
        /* Glare effect styling */
        .js-tilt-glare {
            border-radius: var(--radius-xl);
        }
        
        /* Add depth shadow */
        .category-item::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, rgba(255,255,255,0.1) 0%, rgba(255,255,255,0) 100%);
            border-radius: var(--radius-xl);
            pointer-events: none;
            transform: translateZ(20px);
        }
        
        /* Icon container with 3D effect */
        .category-icon-wrapper {
            width: 80px;
            height: 80px;
            margin: 0 auto var(--space-3);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, rgba(212, 175, 55, 0.1) 0%, rgba(255, 215, 0, 0.05) 100%);
            box-shadow: 
                0 10px 30px rgba(0, 0, 0, 0.1),
                inset 0 1px 0 rgba(255, 255, 255, 0.3);
            transform: translateZ(30px);
            transition: all 0.3s ease;
        }
        
        .category-item:hover .category-icon-wrapper {
            transform: translateZ(50px);
            box-shadow: 
                0 20px 50px rgba(212, 175, 55, 0.3),
                inset 0 1px 0 rgba(255, 255, 255, 0.5);
        }
        
        /* Real image icons */
        .category-icon-image {
            width: 50px;
            height: 50px;
            object-fit: contain;
            filter: drop-shadow(0 4px 8px rgba(0, 0, 0, 0.1));
        }
        
        /* Fallback emoji styling */
        .category-icon-emoji {
            font-size: 40px;
            filter: drop-shadow(0 4px 8px rgba(0, 0, 0, 0.1));
        }
    `;
    document.head.appendChild(style);
}

// Initialize everything when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        add3DDepthStyles();
        init3DTiltEffect();
        console.log('🎨 3D Tilt Effect Initialized!');
    });
} else {
    add3DDepthStyles();
    init3DTiltEffect();
    console.log('🎨 3D Tilt Effect Initialized!');
}
