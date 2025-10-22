(async function () {
  const zeroSix = window.zeroSix || {};
  const settingsApi = zeroSix.settings;
  const dom = zeroSix.dom;

  if (!settingsApi || !dom) {
    console.warn("Zero Six settings or dom utilities unavailable on Twitter.");
    return;
  }

  const STORAGE_KEY = settingsApi.STORAGE_KEY;

  const FEATURE_RULES = {
    hideHomeTimeline: {
      apply(active) {
        dom.toggleHidden(
          "twitter-home",
          [
            'main[role="main"] section[aria-labelledby^="accessible-list"]',
            'main[role="main"] [data-testid="primaryColumn"] section div[data-testid="cellInnerDiv"]',
            'main[role="main"] [data-testid="timeline"]'
          ],
          active
        );
      }
    },
    hideTrends: {
      apply(active) {
        dom.toggleHidden(
          "twitter-trends",
          [
            'aside[aria-label="Trending"]',
            'section[aria-labelledby^="accessible-list-"] [data-testid="trend"]',
            'a[href="/explore/tabs/trending"]',
            '[aria-label="Timeline: Trending now"]'
          ],
          active
        );
      }
    },
    hideWhoToFollow: {
      apply(active) {
        dom.toggleHidden(
          "twitter-who-to-follow",
          [
            '[aria-label="Who to follow"]',
            'section[aria-labelledby^="accessible-list-"] [data-testid="UserCell"]',
            'div[data-testid="sidebarColumn"] [data-testid="UserCell"]'
          ],
          active
        );
      }
    },
    hideNotifications: {
      apply(active) {
        dom.toggleHidden(
          "twitter-notifications",
          [
            'a[aria-label="Notifications"]',
            'a[href="/notifications"]',
            'a[href="/notifications/mentions"]'
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

  const initialSettings = await settingsApi.getSiteSettings("twitter");
  applySettings(initialSettings);

  chrome.storage.onChanged.addListener((changes, areaName) => {
    if (areaName !== "sync" || !changes[STORAGE_KEY]) {
      return;
    }
    const newValue = changes[STORAGE_KEY].newValue;
    if (!newValue) {
      return;
    }
    applySettings(newValue.twitter);
  });
})();
