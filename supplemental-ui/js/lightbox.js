(function () {
  'use strict';

  function init() {
    var diagrams = document.querySelectorAll('.imageblock .content img[src$=".svg"]');
    if (!diagrams.length) return;

    var overlay = document.createElement('div');
    overlay.className = 'diagram-lightbox-overlay';
    overlay.innerHTML =
      '<button type="button" class="diagram-lightbox-close" aria-label="Закрыть">&times;</button>' +
      '<img alt="">' +
      '<div class="diagram-lightbox-hint">Колёсико — масштаб, перетаскивание — Pan, Esc или клик мимо — закрыть</div>';
    document.body.appendChild(overlay);

    var overlayImg = overlay.querySelector('img');
    var closeBtn = overlay.querySelector('.diagram-lightbox-close');
    var lastFocused = null;

    // ---- Зум и перетаскивание ----
    var scale = 1;
    var translateX = 0;
    var translateY = 0;
    var isDragging = false;
    var startX, startY;

    function updateTransform() {
      overlayImg.style.transform = 'translate(' + translateX + 'px, ' + translateY + 'px) scale(' + scale + ')';
    }

    // Сброс трансформаций при открытии
    function resetZoom() {
      scale = 1;
      translateX = 0;
      translateY = 0;
      updateTransform();
    }

    function openLightbox(src, alt) {
      lastFocused = document.activeElement;
      overlayImg.src = src;
      overlayImg.alt = alt || '';
      resetZoom();
      overlay.classList.add('is-open');
      document.documentElement.style.overflow = 'hidden';
      closeBtn.focus();
    }

    function closeLightbox() {
      overlay.classList.remove('is-open');
      document.documentElement.style.overflow = '';
      if (lastFocused && typeof lastFocused.focus === 'function') {
        lastFocused.focus();
      }
    }

    // Закрытие только по фону (overlay) или крестику, не по изображению
    overlay.addEventListener('click', function (event) {
      if (event.target === overlay || event.target === closeBtn) {
        closeLightbox();
      }
    });

    document.addEventListener('keydown', function (event) {
      if (event.key === 'Escape' && overlay.classList.contains('is-open')) {
        closeLightbox();
      }
    });

    // Зум колёсиком
    overlay.addEventListener('wheel', function (event) {
      if (!overlay.classList.contains('is-open')) return;
      event.preventDefault();
      var delta = event.deltaY > 0 ? -0.1 : 0.1;
      var newScale = Math.min(Math.max(0.3, scale + delta), 6);
      // Масштабирование относительно положения курсора (опционально, для точности)
      // Но для простоты оставим обычный линейный зум
      scale = newScale;
      updateTransform();
    });

    // Перетаскивание
    overlay.addEventListener('mousedown', function (event) {
      if (!overlay.classList.contains('is-open')) return;
      if (event.target === overlayImg || event.target === overlay) {
        isDragging = true;
        startX = event.clientX - translateX;
        startY = event.clientY - translateY;
        overlay.style.cursor = 'grabbing';
        event.preventDefault(); // чтобы не выделять текст
      }
    });

    window.addEventListener('mousemove', function (event) {
      if (!isDragging) return;
      translateX = event.clientX - startX;
      translateY = event.clientY - startY;
      updateTransform();
    });

    window.addEventListener('mouseup', function () {
      isDragging = false;
      overlay.style.cursor = 'grab'; // возвращаем, если наведён на фон
    });

    // При закрытии сбрасываем курсор
    function closeAndResetCursor() {
      closeLightbox();
      overlay.style.cursor = '';
    }
    // Переопределим закрытие с учётом курсора
    overlay.addEventListener('click', function (event) {
      if (event.target === overlay || event.target === closeBtn) {
        closeAndResetCursor();
      }
    });
    // Также для Escape
    var originalKeyHandler = function (event) {
      if (event.key === 'Escape' && overlay.classList.contains('is-open')) {
        closeAndResetCursor();
      }
    };
    document.addEventListener('keydown', originalKeyHandler);

    // Отключаем стандартное перетаскивание изображения
    overlayImg.addEventListener('dragstart', function (e) { e.preventDefault(); });

    // Привязка событий к диаграммам
    diagrams.forEach(function (img) {
      img.setAttribute('tabindex', '0');
      img.setAttribute('role', 'button');
      img.setAttribute('aria-label', 'Открыть диаграмму на весь экран (доступен зум)');

      img.addEventListener('click', function () {
        openLightbox(img.currentSrc || img.src, img.alt);
      });

      img.addEventListener('keydown', function (event) {
        if (event.key === 'Enter' || event.key === ' ') {
          event.preventDefault();
          openLightbox(img.currentSrc || img.src, img.alt);
        }
      });
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();