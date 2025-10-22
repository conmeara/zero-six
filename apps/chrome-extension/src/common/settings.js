(function () {
  const STORAGE_KEY = "zeroSixSettings";

  const globalScope = typeof window !== "undefined" ? window : globalThis;
  const defaultSettings = (globalScope.zeroSix && globalScope.zeroSix.defaultSettings) || {};

  function deepMerge(defaultObj, storedObj) {
    if (!storedObj || typeof storedObj !== "object") {
      return JSON.parse(JSON.stringify(defaultObj));
    }

    const result = Array.isArray(defaultObj) ? [] : {};
    for (const key of Object.keys(defaultObj)) {
      const defaultValue = defaultObj[key];
      const storedValue = storedObj[key];
      if (defaultValue && typeof defaultValue === "object" && !Array.isArray(defaultValue)) {
        result[key] = deepMerge(defaultValue, storedValue);
      } else if (storedValue !== undefined) {
        result[key] = storedValue;
      } else {
        result[key] = defaultValue;
      }
    }
    return result;
  }

  async function getAllSettings() {
    return new Promise((resolve) => {
      chrome.storage.sync.get([STORAGE_KEY], (items) => {
        const stored = items[STORAGE_KEY] || {};
        const merged = deepMerge(defaultSettings, stored);
        resolve(merged);
      });
    });
  }

  async function getSiteSettings(siteKey) {
    const settings = await getAllSettings();
    return settings[siteKey] || {};
  }

  async function saveSettings(partial) {
    const current = await getAllSettings();
    const updated = Object.assign({}, current, partial);
    return new Promise((resolve) => {
      chrome.storage.sync.set({ [STORAGE_KEY]: updated }, resolve);
    });
  }

  async function saveSiteSettings(siteKey, siteSettings) {
    const current = await getAllSettings();
    current[siteKey] = Object.assign({}, current[siteKey] || {}, siteSettings);
    return new Promise((resolve) => {
      chrome.storage.sync.set({ [STORAGE_KEY]: current }, resolve);
    });
  }

  if (!globalScope.zeroSix) {
    globalScope.zeroSix = {};
  }

  globalScope.zeroSix.settings = {
    STORAGE_KEY,
    defaultSettings,
    getAllSettings,
    getSiteSettings,
    saveSettings,
    saveSiteSettings
  };
})();
