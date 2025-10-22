# Zero Six

Zero Six is an open-source reimagining of the Undistracted Chrome extension. It hides the feeds, recommendations, and notification triggers that pull you into distraction loops on the web. Today it focuses on the original Undistracted platforms, with an architecture ready for additional services, browsers, and native apps.

## Supported Platforms

| Platform   | Controls |
| ---------- | -------- |
| Facebook   | News Feed, Stories, Watch tab, Marketplace, Notifications |
| YouTube    | Home feed, Up-next sidebar, Comments, End-screen cards, Shorts surface |
| Twitter / X | Home timeline, Trending, Who to follow, Notifications |
| Reddit     | Home feed, Trending modules, Sidebar widgets |
| LinkedIn   | Main feed, Notifications, Messaging overlays |
| Instagram  | Feed, Stories tray, Explore links, Reels links |

All switches can be configured globally (via the options page) and quickly toggled on/off from the popup menu.

## Install (Unpacked)

1. Clone or download this repository.
2. In Chrome/Chromium, open `chrome://extensions`.
3. Enable **Developer mode** (top-right).
4. Choose **Load unpacked** and select the project folder (`zerosix`).
5. Pin the Zero Six action button to your toolbar for quick access.

## Usage

- Click the Zero Six toolbar icon for one-click enable/disable controls per platform.
- Open **Options** (from the popup or the extensions page) to fine-tune each surface you want hidden.
- Changes sync across Chrome instances via `chrome.storage.sync`.

## Project Layout

```
manifest.json              # Extension entry point (Manifest V3)
src/background/            # Service worker for default data and messaging
src/common/                # Shared helpers and default settings
src/contentScripts/        # Platform-specific DOM clean-up scripts
src/options/               # Full settings UI
src/popup/                 # Lightweight toolbar UI
```

## Developing

- Edit the files directly; no build step is required (plain JavaScript/CSS/HTML).
- After changes, reload the extension from the `chrome://extensions` page.
- Use the options page to confirm new toggles appear and behave as expected.

## Roadmap Ideas

1. Expand coverage to additional platforms (TikTok, Gmail, Slack, etc.).
2. Introduce per-site schedules and temporary snoozes.
3. Support Firefox and Safari via WebExtension APIs.
4. Offer profiles or presets (e.g., “Deep Work”, “Casual Browse”).

Contributions are welcome. File issues or open pull requests as you extend Zero Six.
# zero-six
