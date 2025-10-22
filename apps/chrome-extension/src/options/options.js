document.addEventListener("DOMContentLoaded", async () => {
  const zeroSix = window.zeroSix || {};
  const settingsApi = zeroSix.settings;
  const defaults = zeroSix.defaultSettings;
  const root = document.getElementById("options-root");

  if (!settingsApi || !defaults || !root) {
    console.error("Zero Six options bootstrap failed.");
    return;
  }

  const currentSettings = await settingsApi.getAllSettings();

  const siteEntries = Object.entries(defaults).filter(([key]) => key !== "version");

  const toggleGroups = {};

  for (const [siteKey, siteDefaults] of siteEntries) {
    const siteSettings = currentSettings[siteKey] || siteDefaults;
    const card = document.createElement("section");
    card.className = "site-card";

    const header = document.createElement("div");
    header.className = "site-card__header";

    const title = document.createElement("h2");
    title.className = "site-card__title";
    title.textContent = formatLabel(siteKey);

    const enabledToggle = createToggleInput({
      id: `${siteKey}-enabled`,
      label: "Enabled",
      checked: Boolean(siteSettings.enabled),
      onChange: async (checked, checkbox, labelEl) => {
        disableFeatureToggles(siteKey, !checked);
        labelEl.textContent = checked ? "Enabled" : "Disabled";
        try {
          await settingsApi.saveSiteSettings(siteKey, { enabled: checked });
        } catch (error) {
          console.error("Failed to save Zero Six settings", error);
        }
      }
    });

    header.appendChild(title);
    header.appendChild(enabledToggle.wrapper);
    card.appendChild(header);

    enabledToggle.label.textContent = siteSettings.enabled ? "Enabled" : "Disabled";

    toggleGroups[siteKey] = [];

    for (const [featureKey, defaultValue] of Object.entries(siteDefaults)) {
      if (featureKey === "enabled") {
        continue;
      }

      const featureToggle = createToggleInput({
        id: `${siteKey}-${featureKey}`,
        label: formatLabel(featureKey),
        checked: siteSettings[featureKey] !== undefined ? Boolean(siteSettings[featureKey]) : Boolean(defaultValue),
        onChange: async (checked) => {
          try {
            await settingsApi.saveSiteSettings(siteKey, { [featureKey]: checked });
          } catch (error) {
            console.error("Failed to save Zero Six settings", error);
          }
        }
      });

      toggleGroups[siteKey].push(featureToggle.input);

      const row = document.createElement("div");
      row.className = "toggle-row";
      row.appendChild(featureToggle.label);
      row.appendChild(featureToggle.input);
      card.appendChild(row);
    }

    root.appendChild(card);
    disableFeatureToggles(siteKey, !siteSettings.enabled);
  }

  function disableFeatureToggles(siteKey, disabled) {
    const toggles = toggleGroups[siteKey] || [];
    for (const toggle of toggles) {
      toggle.disabled = disabled;
    }
  }

  function createToggleInput({ id, label, checked, onChange }) {
    const labelEl = document.createElement("label");
    labelEl.setAttribute("for", id);
    labelEl.textContent = label;

    const input = document.createElement("input");
    input.type = "checkbox";
    input.id = id;
    input.checked = Boolean(checked);

    input.addEventListener("change", () => {
      onChange(input.checked, input, labelEl);
    });

    return { label: labelEl, input, wrapper: buildHeaderToggle(input, labelEl) };
  }

  function buildHeaderToggle(input, label) {
    const wrapper = document.createElement("div");
    wrapper.className = "header-toggle";
    wrapper.appendChild(label);
    wrapper.appendChild(input);
    return wrapper;
  }

  function formatLabel(key) {
    return key
      .replace(/([A-Z])/g, " $1")
      .replace(/\b\w/g, (char) => char.toUpperCase())
      .replace(/_/g, " ")
      .trim();
  }
});
