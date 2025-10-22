(async function () {
  const zeroSix = window.zeroSix || {};
  const settingsApi = zeroSix.settings;
  const dom = zeroSix.dom;

  if (!settingsApi || !dom) {
    console.warn("Zero Six settings or dom utilities unavailable on YouTube.");
    return;
  }

  const STORAGE_KEY = settingsApi.STORAGE_KEY;

  const FEATURE_RULES = {
    hideHomeFeed: {
      apply(active) {
        if (active) {
          dom.addGlobalCss(
            "youtube-home-feed",
            [
              'ytd-browse[page-subtype="home"] ytd-rich-grid-renderer { display: none !important; }',
              'ytd-browse[page-subtype="home"] ytd-two-column-browse-results-renderer #primary { display: none !important; }'
            ].join("\n")
          );
        } else {
          dom.removeStyle("youtube-home-feed");
        }
      }
    },
    hideSidebar: {
      apply(active) {
        dom.toggleHidden(
          "youtube-sidebar",
          [
            "#related",
            "ytd-watch-next-secondary-results-renderer",
            "ytd-merch-shelf-renderer",
            "#secondary #secondary-inner",
            "ytd-mini-guide-renderer",
            "#guide-inner-content"
          ],
          active
        );
      }
    },
    hideComments: {
      apply(active) {
        dom.toggleHidden("youtube-comments", ["#comments", "ytd-comments", "ytd-comment-thread-renderer"], active);
      }
    },
    hideEndscreen: {
      apply(active) {
        if (active) {
          dom.addGlobalCss(
            "youtube-endscreen",
            [
              ".ytp-endscreen-content { display: none !important; }",
              ".ytp-ce-element { display: none !important; }",
              ".ytp-ce-covering-overlay { display: none !important; }",
              ".ytp-ce-element-shadow { display: none !important; }"
            ].join("\n")
          );
        } else {
          dom.removeStyle("youtube-endscreen");
        }
      }
    },
    hideShorts: {
      apply(active) {
        dom.toggleHidden(
          "youtube-shorts",
          [
            'ytd-rich-section-renderer[section-identifier="shorts-shelf"]',
            "ytd-reel-shelf-renderer",
            'a[title="Shorts"]',
            'ytd-guide-section-renderer a[title="Shorts"]',
            "ytd-rich-grid-slim-media[is-short]",
            "#endpoint[title='Shorts']"
          ],
          active
        );
      }
    }
  };

  function applySettings(siteSettings) {
    const settings = siteSettings || {};
    if (!settings.enabled) {
      for (const feature of Object.values(FEATURE_RULES)) {
        feature.apply(false);
      }
      return;
    }

    for (const [featureKey, feature] of Object.entries(FEATURE_RULES)) {
      feature.apply(Boolean(settings[featureKey]));
    }
  }

  const initialSettings = await settingsApi.getSiteSettings("youtube");
  applySettings(initialSettings);

  chrome.storage.onChanged.addListener((changes, areaName) => {
    if (areaName !== "sync" || !changes[STORAGE_KEY]) {
      return;
    }
    const newValue = changes[STORAGE_KEY].newValue;
    if (!newValue) {
      return;
    }
    applySettings(newValue.youtube);
  });
})();
