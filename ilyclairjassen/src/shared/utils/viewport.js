/**
 * Viewport Management Utility
 * Handles panning and viewport state for the infinite-scroll feel.
 */

let panX = 0;
let panY = 0;
let scale = 1;
let isDragging = false;
let startX = 0;
let startY = 0;
let velocityX = 0;
let velocityY = 0;

export const Viewport = {
  /**
   * Initializes viewport interaction.
   * @param {HTMLElement} worldEl - The element to transform.
   * @param {HTMLElement} containerEl - The interaction container.
   */
  init(worldEl, containerEl) {
    if (!worldEl || !containerEl) return;

    const handlePointerDown = (clientX, clientY) => {
      isDragging = true;
      startX = clientX - panX;
      startY = clientY - panY;
      velocityX = 0;
      velocityY = 0;
    };

    const handlePointerMove = (clientX, clientY) => {
      if (!isDragging) return;
      const nextX = clientX - startX;
      const nextY = clientY - startY;
      velocityX = nextX - panX;
      velocityY = nextY - panY;
      panX = nextX;
      panY = nextY;
      apply(worldEl);
    };

    const handlePointerUp = () => {
      isDragging = false;
    };

    // Mouse Events
    containerEl.addEventListener('mousedown', (e) => {
      // Don't pan if clicking interactive elements
      if (e.target.tagName === 'BUTTON' || e.target.tagName === 'INPUT' || e.target.closest('.photo-frame')) return;
      handlePointerDown(e.clientX, e.clientY);
    });
    window.addEventListener('mousemove', (e) => handlePointerMove(e.clientX, e.clientY));
    window.addEventListener('mouseup', handlePointerUp);

    // Touch Events
    containerEl.addEventListener('touchstart', (e) => {
      if (e.target.tagName === 'BUTTON' || e.target.tagName === 'INPUT' || e.target.closest('.photo-frame')) return;
      handlePointerDown(e.touches[0].clientX, e.touches[0].clientY);
    }, { passive: true });
    containerEl.addEventListener('touchmove', (e) => handlePointerMove(e.touches[0].clientX, e.touches[0].clientY), { passive: true });
    containerEl.addEventListener('touchend', handlePointerUp);

    // Inertia loop
    const friction = 0.95;
    const step = () => {
      if (!isDragging) {
        panX += velocityX;
        panY += velocityY;
        velocityX *= friction;
        velocityY *= friction;
        if (Math.abs(velocityX) > 0.01 || Math.abs(velocityY) > 0.01) {
          apply(worldEl);
        }
      }
      // Global handles for effects (like parallax or canvas draw)
      window._panX = panX;
      window._panY = panY;
      requestAnimationFrame(step);
    };
    step();

    // Initial apply
    apply(worldEl);
  },

  getPos() {
    return { x: panX, y: panY };
  }
};

function apply(el) {
  el.style.transform = `translate3d(${panX}px, ${panY}px, 0) scale(${scale})`;
}
