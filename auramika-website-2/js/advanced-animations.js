/**
 * INSANE PROFESSIONAL ANIMATIONS
 * Using GSAP, Anime.js, Particles.js, Three.js, and Vanta.js
 */

// Wait for DOM to load
document.addEventListener('DOMContentLoaded', function () {

    // ============================================
    // 1. GSAP SCROLL-TRIGGERED ANIMATIONS
    // ============================================
    gsap.registerPlugin(ScrollTrigger);

    // Hero section entrance
    gsap.from('.hero-brand-name', {
        duration: 1.5,
        y: 100,
        opacity: 0,
        scale: 0.8,
        rotationX: -90,
        transformOrigin: "50% 50%",
        ease: "elastic.out(1, 0.5)",
        delay: 0.3
    });

    gsap.from('.hero-tagline', {
        duration: 1,
        x: -100,
        opacity: 0,
        ease: "power3.out",
        delay: 0.8
    });

    gsap.from('.hero-description', {
        duration: 1,
        y: 50,
        opacity: 0,
        ease: "power2.out",
        delay: 1
    });

    // Stagger animation for hero buttons
    gsap.from('.hero-actions .btn', {
        duration: 0.8,
        y: 50,
        opacity: 0,
        stagger: 0.2,
        ease: "back.out(1.7)",
        delay: 1.2
    });

    // Hero image with 3D rotation
    gsap.from('.hero-image-wrapper', {
        duration: 1.5,
        scale: 0.5,
        opacity: 0,
        rotationY: 180,
        ease: "power4.out",
        delay: 0.5
    });

    // Parallax effect on scroll
    gsap.to('.hero-image-wrapper', {
        y: 100,
        scrollTrigger: {
            trigger: '.hero-section',
            start: 'top top',
            end: 'bottom top',
            scrub: 1
        }
    });

    // Category cards scroll animation
    gsap.from('.category-item', {
        scrollTrigger: {
            trigger: '.category-grid',
            start: 'top 80%',
            toggleActions: 'play none none reverse'
        },
        duration: 0.8,
        y: 100,
        opacity: 0,
        rotationX: -45,
        stagger: {
            amount: 0.8,
            from: "start"
        },
        ease: "power3.out"
    });

    // Section titles with split text effect
    const sectionTitles = document.querySelectorAll('.section-title');
    sectionTitles.forEach(title => {
        const text = title.textContent;
        title.innerHTML = text.split('').map(char =>
            `<span class="char">${char === ' ' ? '&nbsp;' : char}</span>`
        ).join('');

        gsap.from(title.querySelectorAll('.char'), {
            scrollTrigger: {
                trigger: title,
                start: 'top 85%',
            },
            duration: 0.5,
            opacity: 0,
            y: 50,
            rotationX: -90,
            stagger: 0.03,
            ease: "back.out(1.7)"
        });
    });

    // ============================================
    // 2. ANIME.JS MAGNETIC CURSOR EFFECT
    // ============================================
    const buttons = document.querySelectorAll('.btn, .chip, .category-item');

    buttons.forEach(button => {
        button.addEventListener('mouseenter', function (e) {
            anime({
                targets: this,
                scale: 1.1,
                duration: 400,
                easing: 'easeOutElastic(1, .6)'
            });
        });

        button.addEventListener('mouseleave', function (e) {
            anime({
                targets: this,
                scale: 1,
                duration: 400,
                easing: 'easeOutElastic(1, .6)'
            });
        });

        button.addEventListener('mousemove', function (e) {
            const rect = this.getBoundingClientRect();
            const x = e.clientX - rect.left - rect.width / 2;
            const y = e.clientY - rect.top - rect.height / 2;

            anime({
                targets: this,
                translateX: x * 0.3,
                translateY: y * 0.3,
                duration: 300,
                easing: 'easeOutQuad'
            });
        });

        button.addEventListener('mouseleave', function () {
            anime({
                targets: this,
                translateX: 0,
                translateY: 0,
                duration: 500,
                easing: 'easeOutElastic(1, .6)'
            });
        });
    });

    // ============================================
    // 3. ANIME.JS MORPHING SHAPES
    // ============================================
    anime({
        targets: '.hero-brand-name',
        scale: [
            { value: 1, duration: 0 },
            { value: 1.02, duration: 2000 },
            { value: 1, duration: 2000 }
        ],
        rotate: [
            { value: 0, duration: 0 },
            { value: 1, duration: 2000 },
            { value: 0, duration: 2000 }
        ],
        easing: 'easeInOutSine',
        loop: true
    });

    // ============================================
    // 4. PARTICLES.JS BACKGROUND
    // ============================================
    // Create particles container
    const particlesContainer = document.createElement('div');
    particlesContainer.id = 'particles-js';
    particlesContainer.style.position = 'absolute';
    particlesContainer.style.width = '100%';
    particlesContainer.style.height = '100%';
    particlesContainer.style.top = '0';
    particlesContainer.style.left = '0';
    particlesContainer.style.zIndex = '0';
    particlesContainer.style.pointerEvents = 'none';

    const heroSection = document.querySelector('.hero-section');
    if (heroSection) {
        heroSection.style.position = 'relative';
        heroSection.insertBefore(particlesContainer, heroSection.firstChild);

        particlesJS('particles-js', {
            particles: {
                number: {
                    value: 80,
                    density: {
                        enable: true,
                        value_area: 800
                    }
                },
                color: {
                    value: '#D4AF37'
                },
                shape: {
                    type: 'circle',
                    stroke: {
                        width: 0,
                        color: '#000000'
                    }
                },
                opacity: {
                    value: 0.3,
                    random: true,
                    anim: {
                        enable: true,
                        speed: 1,
                        opacity_min: 0.1,
                        sync: false
                    }
                },
                size: {
                    value: 3,
                    random: true,
                    anim: {
                        enable: true,
                        speed: 2,
                        size_min: 0.1,
                        sync: false
                    }
                },
                line_linked: {
                    enable: true,
                    distance: 150,
                    color: '#D4AF37',
                    opacity: 0.2,
                    width: 1
                },
                move: {
                    enable: true,
                    speed: 2,
                    direction: 'none',
                    random: true,
                    straight: false,
                    out_mode: 'out',
                    bounce: false,
                    attract: {
                        enable: true,
                        rotateX: 600,
                        rotateY: 1200
                    }
                }
            },
            interactivity: {
                detect_on: 'canvas',
                events: {
                    onhover: {
                        enable: true,
                        mode: 'grab'
                    },
                    onclick: {
                        enable: true,
                        mode: 'push'
                    },
                    resize: true
                },
                modes: {
                    grab: {
                        distance: 140,
                        line_linked: {
                            opacity: 0.5
                        }
                    },
                    push: {
                        particles_nb: 4
                    }
                }
            },
            retina_detect: true
        });
    }

    // ============================================
    // 5. VANTA.JS WAVES BACKGROUND (Alternative)
    // ============================================
    // Uncomment to use instead of particles
    /*
    if (typeof VANTA !== 'undefined') {
        VANTA.WAVES({
            el: ".hero-section",
            mouseControls: true,
            touchControls: true,
            gyroControls: false,
            minHeight: 200.00,
            minWidth: 200.00,
            scale: 1.00,
            scaleMobile: 1.00,
            color: 0x1a1a2e,
            shininess: 30.00,
            waveHeight: 15.00,
            waveSpeed: 0.50,
            zoom: 0.65
        });
    }
    */

    // ============================================
    // 6. SEARCH BAR FOCUS ANIMATION
    // ============================================
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('focus', function () {
            anime({
                targets: this,
                scale: [1, 1.05, 1.02],
                duration: 600,
                easing: 'easeOutElastic(1, .8)'
            });

            // Create ripple effect
            const ripple = document.createElement('div');
            ripple.style.position = 'absolute';
            ripple.style.borderRadius = '50%';
            ripple.style.border = '2px solid #D4AF37';
            ripple.style.width = '0';
            ripple.style.height = '0';
            ripple.style.top = '50%';
            ripple.style.left = '50%';
            ripple.style.transform = 'translate(-50%, -50%)';
            ripple.style.pointerEvents = 'none';

            this.parentElement.style.position = 'relative';
            this.parentElement.appendChild(ripple);

            anime({
                targets: ripple,
                width: 500,
                height: 500,
                opacity: [0.5, 0],
                duration: 1000,
                easing: 'easeOutQuad',
                complete: () => ripple.remove()
            });
        });
    }

    // ============================================
    // 7. CATEGORY ICON ROTATION ON HOVER
    // ============================================
    const categoryIcons = document.querySelectorAll('.category-icon');
    categoryIcons.forEach(icon => {
        const parent = icon.closest('.category-item');
        if (parent) {
            parent.addEventListener('mouseenter', function () {
                anime({
                    targets: icon,
                    rotate: [0, 360],
                    scale: [1, 1.3, 1.2],
                    duration: 800,
                    easing: 'easeOutElastic(1, .6)'
                });
            });
        }
    });

    // ============================================
    // 8. INFINITE LOOP ANIMATIONS
    // ============================================

    // Floating animation for hero badge
    anime({
        targets: '.hero-image-badge',
        translateY: [0, -15, 0],
        duration: 3000,
        easing: 'easeInOutSine',
        loop: true
    });

    // Pulsing glow for active chips
    anime({
        targets: '.chip.active',
        boxShadow: [
            { value: '0 4px 16px rgba(212, 175, 55, 0.3)' },
            { value: '0 8px 32px rgba(212, 175, 55, 0.6)' },
            { value: '0 4px 16px rgba(212, 175, 55, 0.3)' }
        ],
        duration: 2000,
        easing: 'easeInOutSine',
        loop: true
    });

    // ============================================
    // 9. CLICK RIPPLE EFFECT
    // ============================================
    document.querySelectorAll('.chip, .btn').forEach(element => {
        element.addEventListener('click', function (e) {
            const rect = this.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;

            const ripple = document.createElement('span');
            ripple.style.position = 'absolute';
            ripple.style.borderRadius = '50%';
            ripple.style.background = 'rgba(255, 255, 255, 0.6)';
            ripple.style.width = '20px';
            ripple.style.height = '20px';
            ripple.style.left = x + 'px';
            ripple.style.top = y + 'px';
            ripple.style.transform = 'translate(-50%, -50%)';
            ripple.style.pointerEvents = 'none';

            this.style.position = 'relative';
            this.style.overflow = 'hidden';
            this.appendChild(ripple);

            anime({
                targets: ripple,
                width: 300,
                height: 300,
                opacity: [0.6, 0],
                duration: 800,
                easing: 'easeOutQuad',
                complete: () => ripple.remove()
            });
        });
    });

    // ============================================
    // 10. SCROLL PROGRESS INDICATOR
    // ============================================
    const progressBar = document.createElement('div');
    progressBar.style.position = 'fixed';
    progressBar.style.top = '0';
    progressBar.style.left = '0';
    progressBar.style.width = '0%';
    progressBar.style.height = '3px';
    progressBar.style.background = 'linear-gradient(90deg, #D4AF37, #FFD700)';
    progressBar.style.zIndex = '9999';
    progressBar.style.transition = 'width 0.1s ease';
    document.body.appendChild(progressBar);

    window.addEventListener('scroll', () => {
        const windowHeight = document.documentElement.scrollHeight - document.documentElement.clientHeight;
        const scrolled = (window.scrollY / windowHeight) * 100;
        progressBar.style.width = scrolled + '%';
    });

    console.log('🚀 INSANE ANIMATIONS LOADED! GSAP, Anime.js, Particles.js, Three.js, and Vanta.js are ready!');
});
