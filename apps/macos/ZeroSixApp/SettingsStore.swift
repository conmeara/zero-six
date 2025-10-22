import Foundation
#if canImport(AppKit)
import AppKit
#endif

@MainActor
final class SettingsStore: ObservableObject {
    @Published var sites: [SiteSettings]
    @Published var hasUnsyncedChanges: Bool = false
    @Published var lastSyncedAt: Date?
    @Published var banner: SyncBanner?
    @Published var installationStatus: ChromeInstaller.InstallationStatus
    @Published var installationBanner: SyncBanner?
    @Published var isInstallingExtension: Bool = false

    private let storageURL: URL
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        let supportDirectory = SettingsStore.applicationSupportDirectory()
        self.storageURL = supportDirectory.appendingPathComponent("settings.json")
        self.installationStatus = ChromeInstaller.installationStatus()

        if let loaded = SettingsStore.loadSites(from: storageURL, decoder: decoder) {
            self.sites = loaded
        } else {
            self.sites = SettingsStore.defaultSites
        }

        persistSites()
    }

    func handleSettingsMutation() {
        hasUnsyncedChanges = true
        banner = SyncBanner(message: "You have unsynced changes. Copy the JSON to update your extensions.", style: .info)
        persistSites()
    }

    func copySettingsJSONToClipboard() {
        do {
            let payload = try exportPayload()
            guard let jsonString = String(data: payload, encoding: .utf8) else {
                banner = SyncBanner(message: "Failed to encode JSON.", style: .error)
                return
            }
#if canImport(AppKit)
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(jsonString, forType: .string)
#endif
            lastSyncedAt = Date()
            hasUnsyncedChanges = false
            banner = SyncBanner(message: "Settings JSON copied to your clipboard.", style: .success)
        } catch {
            banner = SyncBanner(message: "Copy failed: \(error.localizedDescription)", style: .error)
        }
    }

    func openChromeExtensionStore() {
        guard let url = URL(string: "https://github.com/conmeara/zero-six/tree/main/apps/chrome-extension#install-unpacked") else {
            return
        }
        open(url: url)
    }

    func open(option: InstallOption) {
        switch option.kind {
        case .chrome:
            Task { await installChromeExtension() }
        case .safari:
            banner = SyncBanner(message: "Safari integration is coming soon.", style: .warning)
        case .firefox:
            banner = SyncBanner(message: "Firefox integration is coming soon.", style: .warning)
        }
    }

    func refreshInstallationStatus() {
        installationStatus = ChromeInstaller.installationStatus()
    }

    func installChromeExtension() async {
        if isInstallingExtension { return }
        isInstallingExtension = true
        installationBanner = SyncBanner(message: "Staging Chrome extension…", style: .info)
        let result = await Task.detached(priority: .userInitiated) {
            ChromeInstaller.installExtensionAndHost()
        }.value
        refreshInstallationStatus()
        isInstallingExtension = false
        installationBanner = SyncBanner(message: result.message, style: result.success ? .success : .error)
    }

    func revealSettingsFolder() {
#if canImport(AppKit)
        NSWorkspace.shared.activateFileViewerSelecting([storageURL])
#endif
    }

    func exportPayload() throws -> Data {
        var payload: [String: Any] = ["version": 1]

        for site in sites {
            payload[site.key] = site.toDictionary()
        }

        let json = try JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])
        return json
    }

    private func persistSites() {
        do {
            let data = try encoder.encode(sites)
            try ensureParentDirectoryExists()
            try data.write(to: storageURL, options: [.atomic])
        } catch {
            banner = SyncBanner(message: "Unable to save settings: \(error.localizedDescription)", style: .error)
        }
        refreshInstallationStatus()
    }

    private func ensureParentDirectoryExists() throws {
        let directory = storageURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }

    private static func loadSites(from url: URL, decoder: JSONDecoder) -> [SiteSettings]? {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }

        if let loaded = try? decoder.decode([SiteSettings].self, from: data) {
            return loaded
        }

        return nil
    }

    private static func applicationSupportDirectory() -> URL {
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let base = urls.first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return base.appendingPathComponent("ZeroSix", isDirectory: true)
    }
}

extension SettingsStore {
    static let defaultSites: [SiteSettings] = [
        SiteSettings(
            key: "facebook",
            label: "Facebook",
            enabled: true,
            features: [
                FeatureToggle(key: "hideNewsFeed", label: "Hide News Feed", enabled: true),
                FeatureToggle(key: "hideStories", label: "Hide Stories", enabled: true),
                FeatureToggle(key: "hideWatch", label: "Hide Watch Tab", enabled: true),
                FeatureToggle(key: "hideMarketplace", label: "Hide Marketplace", enabled: false),
                FeatureToggle(key: "hideNotifications", label: "Hide Notifications", enabled: false)
            ]
        ),
        SiteSettings(
            key: "youtube",
            label: "YouTube",
            enabled: true,
            features: [
                FeatureToggle(key: "hideHomeFeed", label: "Hide Home Feed", enabled: true),
                FeatureToggle(key: "hideSidebar", label: "Hide Sidebar Recommendations", enabled: true),
                FeatureToggle(key: "hideComments", label: "Hide Comments", enabled: false),
                FeatureToggle(key: "hideEndscreen", label: "Hide End Screen Cards", enabled: true),
                FeatureToggle(key: "hideShorts", label: "Hide Shorts Surface", enabled: true)
            ]
        ),
        SiteSettings(
            key: "twitter",
            label: "Twitter / X",
            enabled: true,
            features: [
                FeatureToggle(key: "hideHomeTimeline", label: "Hide Home Timeline", enabled: true),
                FeatureToggle(key: "hideTrends", label: "Hide Trending", enabled: true),
                FeatureToggle(key: "hideWhoToFollow", label: "Hide Who to Follow", enabled: true),
                FeatureToggle(key: "hideNotifications", label: "Hide Notifications", enabled: false)
            ]
        ),
        SiteSettings(
            key: "reddit",
            label: "Reddit",
            enabled: true,
            features: [
                FeatureToggle(key: "hideHomeFeed", label: "Hide Home Feed", enabled: true),
                FeatureToggle(key: "hideTrending", label: "Hide Trending Modules", enabled: true),
                FeatureToggle(key: "hideSidebar", label: "Hide Sidebar Widgets", enabled: false)
            ]
        ),
        SiteSettings(
            key: "linkedin",
            label: "LinkedIn",
            enabled: true,
            features: [
                FeatureToggle(key: "hideFeed", label: "Hide Main Feed", enabled: true),
                FeatureToggle(key: "hideNotifications", label: "Hide Notifications", enabled: false),
                FeatureToggle(key: "hideMessaging", label: "Hide Messaging Overlay", enabled: false)
            ]
        ),
        SiteSettings(
            key: "instagram",
            label: "Instagram",
            enabled: true,
            features: [
                FeatureToggle(key: "hideFeed", label: "Hide Feed", enabled: true),
                FeatureToggle(key: "hideStories", label: "Hide Stories", enabled: true),
                FeatureToggle(key: "hideExplore", label: "Hide Explore", enabled: true),
                FeatureToggle(key: "hideReels", label: "Hide Reels", enabled: true)
            ]
        )
    ]
}

extension SettingsStore {
    private func open(url: URL) {
#if canImport(AppKit)
        NSWorkspace.shared.open(url)
#endif
    }
}
