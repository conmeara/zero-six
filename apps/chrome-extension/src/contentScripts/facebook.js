(async function () {
  const zeroSix = window.zeroSix || {};
  const settingsApi = zeroSix.settings;
  const dom = zeroSix.dom;

  if (!settingsApi || !dom) {
    console.warn("Zero Six settings or dom utilities unavailable on Facebook.");
    return;
  }

  const FEATURE_RULES = {
    hideNewsFeed: {
      id: "facebook-feed",
      selectors: [
        '[role="feed"]',
        'div[data-pagelet^="FeedUnit"]',
        'div[data-pagelet^="FeedStory"]',
        'div[data-pagelet="WorkStories"]',
        'div[aria-label="News Feed"]',
        'div[aria-label="Main content"] [role="main"] > div > div > div > div'
      ]
    },
    hideStories: {
      id: "facebook-stories",
      selectors: [
        'div[data-pagelet="Stories"]',
        'div[aria-label="Stories"]',
        'div[aria-label="Stories tray"]',
        'div[data-pagelet^="StoriesTray"]'
      ]
    },
    hideWatch: {
      id: "facebook-watch",
      selectors: [
        'a[aria-label="Watch"]',
        'a[href="/watch/"]',
        'a[href^="/watch/?"]',
        'a[href="/watch/?ref=tab"]',
        'a[aria-label="Video"]'
      ]
    },
    hideMarketplace: {
      id: "facebook-marketplace",
      selectors: [
        'a[aria-label="Marketplace"]',
        'a[href="/marketplace/?ref=bookmark"]',
        'a[href^="/marketplace/?"]'
      ]
    },
    hideNotifications: {
      id: "facebook-notifications",
      selectors: [
        'div[aria-label="Notifications"]',
        'div[aria-label="Notifications, tab 1 of 2"]',
        'a[aria-label="Notifications"]'
      ]
    }
  };

  const STORAGE_KEY = settingsApi.STORAGE_KEY;

  function applyFeature(ruleKey, enabled) {
    const rule = FEATURE_RULES[ruleKey];
    if (!rule) {
      return;
    }
    dom.toggleHidden(rule.id, rule.selectors, enabled);
  }

  function disableAllFeatures() {
    for (const key of Object.keys(FEATURE_RULES)) {
      applyFeature(key, false);
    }
  }

  function applySettings(siteSettings) {
    if (!siteSettings || !siteSettings.enabled) {
      disableAllFeatures();
      return;
    }

    for (const [key, rule] of Object.entries(FEATURE_RULES)) {
      const active = Boolean(siteSettings[key]);
      applyFeature(key, active);
    }
  }

  const initialSettings = await settingsApi.getSiteSettings("facebook");
  applySettings(initialSettings);

  chrome.storage.onChanged.addListener((changes, areaName) => {
    if (areaName !== "sync" || !changes[STORAGE_KEY]) {
      return;
    }
    const newValue = changes[STORAGE_KEY].newValue;
    if (!newValue) {
      return;
    }
    applySettings(newValue.facebook);
  });
})();
