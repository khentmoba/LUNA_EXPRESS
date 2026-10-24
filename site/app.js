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
