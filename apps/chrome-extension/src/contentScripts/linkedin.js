(async function () {
  const zeroSix = window.zeroSix || {};
  const settingsApi = zeroSix.settings;
  const dom = zeroSix.dom;

  if (!settingsApi || !dom) {
    console.warn("Zero Six settings or dom utilities unavailable on LinkedIn.");
    return;
  }

  const STORAGE_KEY = settingsApi.STORAGE_KEY;

  const FEATURE_RULES = {
    hideFeed: {
      apply(active) {
        dom.toggleHidden(
          "linkedin-feed",
          [
            "main.scaffold-layout__main",
            ".scaffold-layout__main",
            ".feed-shared-update-v2",
            "div[data-view-name='feed_all_updates']"
          ],
          active
        );
      }
    },
    hideNotifications: {
      apply(active) {
        dom.toggleHidden(
          "linkedin-notifications",
          [
            'a[data-test-global-nav-link="notifications"]',
            'a[href*="/notifications/"]',
            'button[data-test-global-nav-link="notifications"]'
          ],
          active
        );
      }
    },
    hideMessaging: {
      apply(active) {
        dom.toggleHidden(
          "linkedin-messaging",
          [
            'a[data-test-global-nav-link="messaging"]',
            'button[data-test-global-nav-link="messaging"]',
            ".msg-overlay-list-bubble",
            ".msg-overlay-container"
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

  const initialSettings = await settingsApi.getSiteSettings("linkedin");
  applySettings(initialSettings);

  chrome.storage.onChanged.addListener((changes, areaName) => {
    if (areaName !== "sync" || !changes[STORAGE_KEY]) {
      return;
    }
    const newValue = changes[STORAGE_KEY].newValue;
    if (!newValue) {
      return;
    }
    applySettings(newValue.linkedin);
  });
})();
