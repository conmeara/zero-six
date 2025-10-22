(function (global) {
  const defaultSettings = {
    version: 1,
    facebook: {
      enabled: true,
      hideNewsFeed: true,
      hideStories: true,
      hideWatch: true,
      hideMarketplace: false,
      hideNotifications: false
    },
    youtube: {
      enabled: true,
      hideHomeFeed: true,
      hideSidebar: true,
      hideComments: false,
      hideEndscreen: true,
      hideShorts: true
    },
    twitter: {
      enabled: true,
      hideHomeTimeline: true,
      hideTrends: true,
      hideWhoToFollow: true,
      hideNotifications: false
    },
    reddit: {
      enabled: true,
      hideHomeFeed: true,
      hideTrending: true,
      hideSidebar: false
    },
    linkedin: {
      enabled: true,
      hideFeed: true,
      hideNotifications: false,
      hideMessaging: false
    },
    instagram: {
      enabled: true,
      hideFeed: true,
      hideStories: true,
      hideExplore: true,
      hideReels: true
    }
  };

  global.zeroSix = global.zeroSix || {};
  global.zeroSix.defaultSettings = defaultSettings;
})(typeof window !== "undefined" ? window : globalThis);
