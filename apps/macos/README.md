# Zero Six macOS App

The Zero Six dashboard is a SwiftUI macOS app that manages the master configuration for every supported platform. Today it lets you adjust settings, persists them to disk, and exports a JSON payload that the Chrome extension understands. Upcoming releases will automate installing and syncing extensions directly from the app.

## Build

1. Open `apps/ZeroSix.xcworkspace` (or `apps/macos/ZeroSixApp.xcodeproj`) in Xcode 15 or later.
2. Select the `ZeroSixApp` scheme and run it on **My Mac** (macOS 13+).
3. The app stores state in `~/Library/Application Support/ZeroSix/settings.json`; delete that file to reset defaults.
4. Refresh the packaged Chrome extension archive with `scripts/package-extension.sh` before archiving the macOS app.
5. The installer writes to Chrome's `External Extensions` and `NativeMessagingHosts` directories, so the app will require appropriate App Sandbox entitlements or Full Disk Access when notarised.

## Features

- Configure per-platform toggles that mirror the Chrome extension.
- Persist settings locally with detection for unsynced changes.
- Copy the JSON payload for manual syncing to the extension (`Copy settings JSON` in the toolbar).
- One-click staging for the Chrome extension and native messaging host (writes to Chrome’s external extension + native messaging directories).
- Quick links to install instructions, app support folder, and future distribution targets.

## Manual Sync (Chrome)

1. Click **Install on Chrome** inside the macOS app to stage the extension + host. Restart Chrome and accept the enable prompt.
2. Click **Copy settings JSON** if you need to push the latest config manually.
3. (Fallback) If required, open `chrome://extensions`, inspect the service worker, and run:

   ```js
   const payload = /* paste JSON from clipboard */;
   chrome.storage.sync.set({ zeroSixSettings: payload });
   ```

## Next Steps

- Bundle the Chrome extension inside the app and deliver one-click install via Chrome’s external-extension workflow.
- Packaged artifacts should be copied into `apps/macos/ZeroSixApp/Resources/ChromeExtension` so they ship with the bundle.
- Add a native messaging helper so the extension can push/pull settings without copy/paste.
- Expand the workspace with iOS/iPadOS/visionOS targets once the macOS flow is solid.
