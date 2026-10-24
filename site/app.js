/* Sticky navigation state. */
(function () {
  'use strict';
  var bar = document.querySelector('.bar');

  if (bar) {
    var stuck = false;
    var onScroll = function () {
      var next = window.scrollY > 6;
      if (next !== stuck) {
        stuck = next;
        bar.classList.toggle('is-stuck', stuck);
      }
    };
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
  }
})();

/* Motion that plays once as each part arrives (see Scroll motion in styles.css). The hidden states
   only apply once this runs, so without script or with reduced motion the page stays static. */
(function () {
  'use strict';
  if (!('IntersectionObserver' in window)) return;
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

  var sheet = document.querySelector('.board__cols');
  var wall = document.querySelector('.window__wall');
  if (!sheet || !wall) return;

  // Lines print in bands across the columns, so each row takes its line number within its column.
  // When the columns stack (phone), the count runs on, so the board still prints top to bottom.
  var numberLines = function () {
    var cols = [].slice.call(sheet.children);
    var stacked = cols.length > 1 && cols[1].getBoundingClientRect().top > cols[0].getBoundingClientRect().top + 1;
    var line = 0;
    cols.forEach(function (col) {
      var rows = col.querySelectorAll('.row');
      for (var i = 0; i < rows.length; i++) rows[i].style.setProperty('--i', line + i);
      if (stacked) line += rows.length;
    });
  };

  var arrive = function (watch, target, className, prepare) {
    var observer = new IntersectionObserver(function (entries) {
      if (!entries[0].isIntersecting) return;
      if (prepare) prepare();
      target.classList.add(className);
      observer.disconnect();
    }, { threshold: 0.1 });
    observer.observe(watch);
  };

  document.documentElement.classList.add('js-print');
  arrive(sheet, document.querySelector('.board'), 'is-printing', numberLines);
  arrive(wall, document.querySelector('.window'), 'is-pinning');
})();
