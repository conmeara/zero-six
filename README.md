# Zero Six

Zero Six keeps the distracting surfaces of social platforms under control. The project contains two deliverables:

- `apps/chrome-extension` – a Manifest V3 Chrome extension that hides feeds, stories, recommendations, and notifications across Facebook, YouTube, Twitter/X, Reddit, LinkedIn, and Instagram.
- `apps/macos` – a SwiftUI companion app that manages the master configuration and now stages the Chrome extension + native messaging bridge automatically.

## Getting Started

1. Clone the repository.
2. Pick the app you want to work on:
   - **Chrome extension:** see `apps/chrome-extension/README.md` for load-unpacked instructions and selector details.
   - **macOS app:** open `apps/ZeroSix.xcworkspace` (or the `ZeroSixApp.xcodeproj`) in Xcode 15+, then build the `ZeroSixApp` scheme for `My Mac`.

## Repository Layout

```
apps/
  chrome-extension/    # Manifest, shared scripts, content scripts, popup/options UI
  macos/
    ZeroSixApp/        # Swift sources, assets, resources
    ZeroSixApp.xcodeproj
  ZeroSix.xcworkspace  # Shared workspace for macOS + future Apple platform targets
scripts/               # Utility scripts (e.g., package-extension.sh)
LICENSE                # MIT
```

## Roadmap

The companion app is being prepared to deliver a one-click install experience:

1. Harden the new one-click Chrome installer (error states, progress, user messaging) and ship notarized builds.
2. Extend the native messaging bridge with real-time sync instead of manual copy/paste fallbacks.
3. Add Safari and Firefox variants, all driven from the same settings store and UI.

Contributions are welcome—open an issue or PR with improvements, selectors, or integration work.
