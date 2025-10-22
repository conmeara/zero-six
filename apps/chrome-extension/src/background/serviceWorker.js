/* global chrome */
importScripts("../common/defaultSettings.js");

const STORAGE_KEY = "zeroSixSettings";
const defaultSettings = (self.zeroSix && self.zeroSix.defaultSettings) || {};
const HOST_NAME = "app.zerosix.host";

let nativeMessagingAvailable = false;

async function sendNativeMessage(payload) {
  return new Promise((resolve, reject) => {
    chrome.runtime.sendNativeMessage(HOST_NAME, payload, (response) => {
      if (chrome.runtime.lastError) {
        nativeMessagingAvailable = false;
        reject(new Error(chrome.runtime.lastError.message));
        return;
      }
      nativeMessagingAvailable = true;
      resolve(response);
    });
  });
}

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

async function ensureDefaultSettings() {
  return new Promise((resolve) => {
    chrome.storage.sync.get([STORAGE_KEY], (items) => {
      const existing = items[STORAGE_KEY];
      if (!existing) {
        chrome.storage.sync.set({ [STORAGE_KEY]: defaultSettings }, resolve);
        return;
      }
      const merged = deepMerge(defaultSettings, existing);
      chrome.storage.sync.set({ [STORAGE_KEY]: merged }, resolve);
    });
  });
}

async function syncFromNativeHost() {
  try {
    const response = await sendNativeMessage({ type: "getSettings" });
    if (response && response.settings) {
      const merged = deepMerge(defaultSettings, response.settings);
      await chrome.storage.sync.set({ [STORAGE_KEY]: merged });
      chrome.runtime.sendMessage({ type: "ZERO_SIX_SETTINGS_SYNCED" }).catch(() => {});
    }
  } catch (error) {
    console.debug("Zero Six native sync unavailable", error?.message || error);
  }
}

chrome.runtime.onInstalled.addListener(async () => {
  await ensureDefaultSettings();
  await syncFromNativeHost();
});

chrome.runtime.onStartup.addListener(async () => {
  await ensureDefaultSettings();
  await syncFromNativeHost();
});

chrome.storage.onChanged.addListener(async (changes, areaName) => {
  if (areaName !== "sync" || !changes[STORAGE_KEY]) {
    return;
  }

  const newValue = changes[STORAGE_KEY].newValue;
  if (!newValue) {
    return;
  }

  try {
    await sendNativeMessage({ type: "saveSettings", settings: newValue });
  } catch (error) {
    console.debug("Zero Six native host not available to persist settings", error?.message || error);
  }
});

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message?.type === "ZERO_SIX_GET_DEFAULTS") {
    sendResponse({ defaults: defaultSettings });
    return true;
  }
  if (message?.type === "ZERO_SIX_NATIVE_STATUS") {
    sendResponse({ nativeMessagingAvailable });
    return true;
  }
  if (message?.type === "ZERO_SIX_SYNC_FROM_NATIVE") {
    syncFromNativeHost()
      .then(() => sendResponse({ ok: true }))
      .catch((error) => sendResponse({ ok: false, message: error?.message || String(error) }));
    return true;
  }
  return false;
});
