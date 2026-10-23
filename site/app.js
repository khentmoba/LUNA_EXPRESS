/* Fare rail: ₱39 a kilometre, the same rule the app uses.
   Also the only sticky-state behaviour on the page. */

(function () {
  'use strict';

  var FEE = 39;
  var MIN = 1;
  var MAX = 12;

  var rail = document.getElementById('rail');
  var bar = document.querySelector('.bar');

  function reduceMotion() {
    return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  }

  if (rail) {
    var needle = rail.querySelector('.rail__needle');
    var tag = rail.querySelector('[data-km]');
    var pesos = document.querySelector('[data-peso]');
    var fareRow = document.querySelector('[data-fares]');
    var fares = [];
    var km = 3;
    var dragging = false;

    if (fareRow) {
      for (var i = MIN; i <= MAX; i += 1) {
        var cell = document.createElement('em');
        cell.style.setProperty('--i', String(i));
        cell.textContent = String(i * FEE);
        fareRow.appendChild(cell);
        fares.push(cell);
      }
    }

    var money = function (n) {
      return '₱' + n.toLocaleString('en-PH');
    };

    function render(next) {
      km = Math.min(MAX, Math.max(MIN, Math.round(next)));
      var fee = km * FEE;
      rail.style.setProperty('--v', km);
      rail.setAttribute('aria-valuenow', String(km));
      rail.setAttribute(
        'aria-valuetext',
        km + ' kilometre' + (km === 1 ? '' : 's') + ', ' + fee + ' pesos estimated delivery'
      );
      if (tag) {
        tag.textContent = km + ' km';
        tag.style.transform =
          'translateX(' + (km <= 2 ? '-22%' : km >= 11 ? '-78%' : '-50%') + ')';
      }
      if (pesos) pesos.textContent = money(fee);
      for (var i = 0; i < fares.length; i += 1) {
        fares[i].classList.toggle('is-active', i + MIN === km);
      }
    }

    function kmAt(event) {
      var box = rail.getBoundingClientRect();
      var x = event.clientX;
      var ratio = (x - box.left) / box.width;
      return MIN + ratio * (MAX - MIN);
    }

    rail.addEventListener('pointerdown', function (event) {
      dragging = true;
      rail.classList.add('is-dragging');
      if (rail.setPointerCapture) rail.setPointerCapture(event.pointerId);
      render(kmAt(event));
      event.preventDefault();
    });

    rail.addEventListener('pointermove', function (event) {
      if (dragging) render(kmAt(event));
    });

    function stop() {
      dragging = false;
      rail.classList.remove('is-dragging');
    }
    rail.addEventListener('pointerup', stop);
    rail.addEventListener('pointercancel', stop);
    rail.addEventListener('lostpointercapture', stop);

    rail.addEventListener('keydown', function (event) {
      var step = { ArrowRight: 1, ArrowUp: 1, ArrowLeft: -1, ArrowDown: -1, PageUp: 3, PageDown: -3 }[event.key];
      if (step) {
        event.preventDefault();
        render(km + step);
      } else if (event.key === 'Home') {
        event.preventDefault();
        render(MIN);
      } else if (event.key === 'End') {
        event.preventDefault();
        render(MAX);
      }
    });

    render(3);

    if (!reduceMotion() && needle) {
      needle.style.transition = 'none';
      rail.style.setProperty('--v', MIN);
      requestAnimationFrame(function () {
        requestAnimationFrame(function () {
          needle.style.transition = '';
          rail.style.setProperty('--v', 3);
        });
      });
    }
  }

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
