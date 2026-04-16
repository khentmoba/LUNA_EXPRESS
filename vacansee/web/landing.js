// VacanSee Landing Page JavaScript
// Handles navigation, scroll effects, and interactions

/**
 * Navigate to a specific path
 * @param {string} path - The path to navigate to
 */
function navigateTo(path) {
    window.location.href = path;
}

/**
 * Smooth scroll to a section by ID
 * @param {string} sectionId - The ID of the section to scroll to
 */
function scrollToSection(sectionId) {
    const element = document.getElementById(sectionId);
    if (element) {
        element.scrollIntoView({ behavior: 'smooth' });
    }
}

/**
 * Handle navbar scroll effect
 * Adds 'scrolled' class to navbar when user scrolls down
 */
function handleNavbarScroll() {
    const navbar = document.getElementById('navbar');
    if (window.scrollY > 50) {
        navbar.classList.add('scrolled');
    } else {
        navbar.classList.remove('scrolled');
    }
}

/**
 * Initialize all event listeners
 */
function init() {
    // Navbar scroll effect
    window.addEventListener('scroll', handleNavbarScroll);
    
    // Check initial scroll position
    handleNavbarScroll();
    
    // Add click handlers for smooth scroll links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            const targetId = this.getAttribute('href').substring(1);
            scrollToSection(targetId);
        });
    });
    
    // Intersection Observer for fade-in animations
    const observerOptions = {
        root: null,
        rootMargin: '0px',
        threshold: 0.1
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('fade-in-visible');
            }
        });
    }, observerOptions);
    
    // Observe all cards for animation
    document.querySelectorAll('.feature-card, .role-card').forEach(card => {
        card.classList.add('fade-in');
        observer.observe(card);
    });
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', init);

// Handle logo image error - fallback to placeholder
document.addEventListener('DOMContentLoaded', function() {
    const logos = document.querySelectorAll('img[alt="VacanSee Logo"]');
    logos.forEach(logo => {
        logo.addEventListener('error', function() {
            // Create SVG placeholder if logo fails to load
            const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
            svg.setAttribute('width', this.width);
            svg.setAttribute('height', this.height);
            svg.setAttribute('viewBox', '0 0 64 64');
            svg.style.background = '#5287B2';
            svg.style.borderRadius = '12px';
            
            const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
            text.setAttribute('x', '50%');
            text.setAttribute('y', '50%');
            text.setAttribute('text-anchor', 'middle');
            text.setAttribute('dominant-baseline', 'middle');
            text.setAttribute('fill', 'white');
            text.setAttribute('font-family', 'Poppins, sans-serif');
            text.setAttribute('font-weight', '700');
            text.setAttribute('font-size', '28');
            text.textContent = 'V';
            
            svg.appendChild(text);
            this.parentNode.replaceChild(svg, this);
        });
    });
});
