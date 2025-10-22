(async function () {
  const zeroSix = window.zeroSix || {};
  const settingsApi = zeroSix.settings;
  const dom = zeroSix.dom;

  if (!settingsApi || !dom) {
    console.warn("Zero Six settings or dom utilities unavailable on Instagram.");
    return;
  }

  const STORAGE_KEY = settingsApi.STORAGE_KEY;

  const FEATURE_RULES = {
    hideFeed: {
      apply(active) {
        dom.toggleHidden(
          "instagram-feed",
          [
            'main[role="main"] article',
            'main[role="main"] section',
            'div[role="main"] article',
            'div[role="main"] main > div > div'
          ],
          active
        );
      }
    },
    hideStories: {
      apply(active) {
        dom.toggleHidden(
          "instagram-stories",
          [
            'main[role="main"] [aria-label="Stories"]',
            'main[role="main"] section[aria-label="Stories"]',
            'main[role="main"] div[style*="--base-tray-height"]'
          ],
          active
        );
      }
    },
    hideExplore: {
      apply(active) {
        dom.toggleHidden(
          "instagram-explore",
          [
            'a[href="/explore/"]',
            'a[href^="/explore/"]',
            '[role="navigation"] a[href="/explore/"]'
          ],
          active
        );
      }
    },
    hideReels: {
      apply(active) {
        dom.toggleHidden(
          "instagram-reels",
          [
            'a[href="/reels/"]',
            'a[href^="/reels/"]',
            'main[role="main"] section[aria-label="Reels"]'
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

  const initialSettings = await settingsApi.getSiteSettings("instagram");
  applySettings(initialSettings);

  chrome.storage.onChanged.addListener((changes, areaName) => {
    if (areaName !== "sync" || !changes[STORAGE_KEY]) {
      return;
    }
    const newValue = changes[STORAGE_KEY].newValue;
    if (!newValue) {
      return;
    }
    applySettings(newValue.instagram);
  });
})();
