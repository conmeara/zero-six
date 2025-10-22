# Bundled Chrome Extension (Future Use)

When we automate the installation flow, package the extension from `apps/chrome-extension` and drop the CRX or zipped payload in this folder. The macOS build script will ship the bundle inside the app and expose it through the "Install Extension" action.

Suggested build step (to be scripted):

Run `scripts/package-extension.sh` from the repo root to refresh the archive before building the macOS app. The native messaging host template (`ZeroSixHost.swift.txt`) lives alongside the archive and is copied into the app bundle (renamed to `.swift` during installation), so edits here feed straight into the installer logic.

The macOS app can then unzip and stage the manifest into Chrome’s External Extensions directory.
