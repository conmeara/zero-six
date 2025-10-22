document.addEventListener("DOMContentLoaded", async () => {
  const zeroSix = window.zeroSix || {};
  const settingsApi = zeroSix.settings;
  const defaults = zeroSix.defaultSettings;
  const root = document.getElementById("popup-root");
  const openOptionsButton = document.getElementById("open-options");

  if (!settingsApi || !defaults || !root || !openOptionsButton) {
    console.error("Zero Six popup bootstrap failed.");
    return;
  }

  openOptionsButton.addEventListener("click", () => {
    if (chrome.runtime.openOptionsPage) {
      chrome.runtime.openOptionsPage();
    } else {
      window.open(chrome.runtime.getURL("src/options/options.html"));
    }
  });

  const currentSettings = await settingsApi.getAllSettings();

  const siteEntries = Object.entries(defaults).filter(([key]) => key !== "version");

  for (const [siteKey, siteDefaults] of siteEntries) {
    const siteSettings = currentSettings[siteKey] || siteDefaults;
    const item = document.createElement("div");
    item.className = "toggle-item";

    const label = document.createElement("strong");
    label.textContent = formatLabel(siteKey);

    const toggle = document.createElement("input");
    toggle.type = "checkbox";
    toggle.checked = Boolean(siteSettings.enabled);

    toggle.addEventListener("change", async () => {
      try {
        await settingsApi.saveSiteSettings(siteKey, { enabled: toggle.checked });
      } catch (error) {
        console.error("Failed to update Zero Six settings", error);
      }
    });

    item.appendChild(label);
    item.appendChild(toggle);
    root.appendChild(item);
  }

  function formatLabel(key) {
    return key
      .replace(/([A-Z])/g, " $1")
      .replace(/\b\w/g, (char) => char.toUpperCase())
      .trim();
  }
});
