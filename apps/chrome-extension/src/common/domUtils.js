(function () {
  const STYLE_PREFIX = "zero-six-style-";

  function injectStyle(id, css) {
    const styleId = STYLE_PREFIX + id;
    let style = document.getElementById(styleId);
    if (!style) {
      style = document.createElement("style");
      style.id = styleId;
      document.head.appendChild(style);
    }
    if (style.textContent !== css) {
      style.textContent = css;
    }
    return style;
  }

  function hideWithCss(id, selectors) {
    const selectorList = Array.isArray(selectors) ? selectors : [selectors];
    const css = selectorList.map((selector) => `${selector} { display: none !important; }`).join("\n");
    injectStyle(id, css);
  }

  function removeStyle(id) {
    const styleId = STYLE_PREFIX + id;
    const style = document.getElementById(styleId);
    if (style) {
      style.remove();
    }
  }

  function toggleHidden(id, selectors, active) {
    if (active) {
      hideWithCss(id, selectors);
    } else {
      removeStyle(id);
    }
  }

  function addGlobalCss(id, cssRules) {
    injectStyle(id, cssRules);
  }

  function waitForElement(selector, callback, options = {}) {
    const { timeout = 5000, root = document.body } = options;

    if (!root) {
      return () => {};
    }

    const existing = root.querySelector(selector);
    if (existing) {
      callback(existing);
      return () => {};
    }

    const observer = new MutationObserver(() => {
      const found = root.querySelector(selector);
      if (found) {
        observer.disconnect();
        callback(found);
      }
    });

    observer.observe(root, { childList: true, subtree: true });

    if (timeout > 0) {
      setTimeout(() => observer.disconnect(), timeout);
    }

    return () => observer.disconnect();
  }

  if (!window.zeroSix) {
    window.zeroSix = {};
  }

  window.zeroSix.dom = {
    injectStyle,
    hideWithCss,
    toggleHidden,
    removeStyle,
    addGlobalCss,
    waitForElement
  };
})();
