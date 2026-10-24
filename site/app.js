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

/* Find us: the map or the street view, one at a time. Without script both stay on the page. */
(function () {
  'use strict';
  var view = document.querySelector('.locate');
  if (!view) return;

  var tabs = [].slice.call(view.querySelectorAll('[data-show]'));
  var panels = [].slice.call(view.querySelectorAll('[data-panel]'));

  var show = function (name) {
    tabs.forEach(function (tab) {
      tab.setAttribute('aria-pressed', String(tab.getAttribute('data-show') === name));
    });
    panels.forEach(function (panel) {
      panel.classList.toggle('is-active', panel.getAttribute('data-panel') === name);
    });
  };

  document.documentElement.classList.add('js-view');
  tabs.forEach(function (tab) {
    tab.addEventListener('click', function () {
      show(tab.getAttribute('data-show'));
    });
  });
  show('map');
})();
