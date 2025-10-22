import Foundation

enum ChromeIntegration {
    static func instructionsMarkdown() -> String {
        """
        1. Click **Install on Chrome** to stage the extension and native host. Relaunch Chrome and enable Zero Six when prompted.
        2. If you need to push settings manually, use **Copy settings JSON** in the Mac app.
        3. Open `chrome://extensions`, locate **Zero Six**, and click **service worker** under inspect views.
        4. In the console, run:
           ```js
           const payload = /* paste JSON here */;
           chrome.storage.sync.set({ zeroSixSettings: payload });
           ```
        5. Refresh any open social tabs to apply the updated configuration.
        """
    }
}
