# Zero Six Chrome Extension

Zero Six hides distracting surfaces across the social web. The extension ships with per-site toggles that remove feeds, stories, recommendations, notifications, and other attention traps from Facebook, YouTube, Twitter/X, Reddit, LinkedIn, and Instagram.

## Supported Surfaces

| Platform     | Controls |
| ------------ | -------- |
| Facebook     | News Feed, Stories, Watch tab, Marketplace, Notifications |
| YouTube      | Home feed, Up-next sidebar, Comments, End-screen cards, Shorts surface |
| Twitter / X  | Home timeline, Trending, Who to follow, Notifications |
| Reddit       | Home feed, Trending modules, Sidebar widgets |
| LinkedIn     | Main feed, Notifications, Messaging overlays |
| Instagram    | Feed, Stories tray, Explore links, Reels links |

## Install (Unpacked)

1. `git clone https://github.com/conmeara/zero-six.git`
2. In Chrome/Chromium open `chrome://extensions`.
3. Enable **Developer mode**.
4. Click **Load unpacked** and choose `apps/chrome-extension`.
5. Pin the Zero Six toolbar icon for quick access.

## Usage

- Use the popup for one-click enable/disable per platform.
- Open the options page to fine-tune individual surfaces (feed, stories, shorts, etc.).
- Settings persist via `chrome.storage.sync`, so they travel with your Chrome profile.
- When the macOS companion app is running, the extension syncs with it through a native messaging host.
- If the host is missing, fall back to **Copy settings JSON** in the Mac app and paste it via the developer console as described in `apps/macos/README.md`.

## Structure

```
manifest.json            # Manifest V3 definition + nativeMessaging permission + key
src/background/          # Service worker for seeding defaults + native host sync
src/common/              # Shared utilities and settings helpers
src/contentScripts/      # Platform-specific DOM cleanse logic
src/options/             # Full settings dashboard
src/popup/               # Toolbar popup experience
```

## Development Tips

- Selector drift happens often; use the options toggles to isolate issues while you inspect DOM changes.
- Keep CSS selectors minimal and prefer `toggleHidden` helpers to avoid layout thrash.
- When adding a new platform, extend `src/common/defaultSettings.js`, add the content script, and wire it in `manifest.json`.

Contributions welcome—open a PR with improved selectors, new platforms, or ergonomics.
