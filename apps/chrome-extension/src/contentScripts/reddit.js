(async function () {
  const zeroSix = window.zeroSix || {};
  const settingsApi = zeroSix.settings;
  const dom = zeroSix.dom;

  if (!settingsApi || !dom) {
    console.warn("Zero Six settings or dom utilities unavailable on Reddit.");
    return;
  }

  const STORAGE_KEY = settingsApi.STORAGE_KEY;

  const FEATURE_RULES = {
    hideHomeFeed: {
      apply(active) {
        dom.toggleHidden(
          "reddit-feed",
          [
            'main[role="main"] .rpBJOHq2PR60pnwJlUyP0',
            'main[role="main"] [data-testid="post-container"]',
            'div[data-testid="post-list"]'
          ],
          active
        );
      }
    },
    hideTrending: {
      apply(active) {
        dom.toggleHidden(
          "reddit-trending",
          [
            '[data-testid="trending-subreddits"]',
            '[data-testid="trending-content"]',
            'div[data-testid="trendingPosts"]',
            'div[data-testid="trendingToday"]'
          ],
          active
        );
      }
    },
    hideSidebar: {
      apply(active) {
        dom.toggleHidden(
          "reddit-sidebar",
          [
            'aside[data-testid="right-sidebar"]',
            '.ListingLayout-outerContainer > .ListingLayout-sidebar',
            'div[data-testid="widgets-column"]'
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

  const initialSettings = await settingsApi.getSiteSettings("reddit");
  applySettings(initialSettings);

  chrome.storage.onChanged.addListener((changes, areaName) => {
    if (areaName !== "sync" || !changes[STORAGE_KEY]) {
      return;
    }
    const newValue = changes[STORAGE_KEY].newValue;
    if (!newValue) {
      return;
    }
    applySettings(newValue.reddit);
  });
})();
