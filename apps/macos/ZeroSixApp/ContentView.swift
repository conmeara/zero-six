import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

struct ContentView: View {
    @EnvironmentObject private var store: SettingsStore
    @State private var showingInstructions = false

    private let installOptions: [InstallOption] = [
        .safari,
        .firefox
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    heroHeader
                    installSection
                    settingsSection
                    syncSection
                }
                .padding(24)
            }
            .navigationTitle("Zero Six Dashboard")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        store.copySettingsJSONToClipboard()
                    } label: {
                        Label("Copy settings JSON", systemImage: "doc.on.doc")
                    }
                    .help("Copies the current configuration to your clipboard so you can paste it into Chrome.")

                    Menu {
                        Button("Open Chrome Extension Page") {
                            store.openChromeExtensionStore()
                        }
                        Button("Open Application Support Folder") {
                            store.revealSettingsFolder()
                        }
                        Divider()
                        Button("View Sync Instructions") {
                            showingInstructions = true
                        }
                    } label: {
                        Label("Actions", systemImage: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingInstructions) {
                SyncInstructionsView(
                    isPresented: $showingInstructions,
                    instructions: ChromeIntegration.instructionsMarkdown()
                )
            }
        }
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Zero Six")
                .font(.system(size: 42, weight: .bold, design: .rounded))
            Text("Stay in control across every browser. Configure what to hide on each platform, then sync the setup to your installed extensions.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var installSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Install Zero Six")
                .font(.headline)
            Text("Choose your browser to install the companion extension. Native integrations for more browsers are coming soon.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            VStack(spacing: 12) {
                ChromeInstallCard()
                ForEach(installOptions) { option in
                    InstallOptionButton(option: option) {
                        store.open(option: option)
                    }
                }
            }
        }
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Platform Controls")
                .font(.headline)
            Text("Update the default switches you want Zero Six to enforce. These settings are saved on your Mac and can be applied to every browser extension.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 16) {
                ForEach($store.sites) { $site in
                    SiteSettingsCard(site: $site) {
                        store.handleSettingsMutation()
                    }
                }
            }
        }
    }

    private var syncSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sync to Extensions")
                .font(.headline)
            SyncStatusView()
        }
    }
}

struct SettingsPane: View {
    @EnvironmentObject private var store: SettingsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Default Settings")
                .font(.title2)
                .bold()
            Text("Adjust the master configuration that powers every Zero Six integration. These settings sync via iCloud for future iOS and visionOS apps.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView {
                VStack(spacing: 16) {
                    ChromeInstallCard()
                    ForEach($store.sites) { $site in
                        SiteSettingsCard(site: $site) {
                            store.handleSettingsMutation()
                        }
                    }
                }
            }
        }
        .padding(24)
        .frame(minWidth: 420, idealWidth: 480)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SettingsStore())
            .frame(width: 900, height: 720)
    }
}

struct ChromeInstallCard: View {
    @EnvironmentObject private var store: SettingsStore

    private var statusText: String {
        store.installationStatus.extensionInstalled ? "Extension staged" : "Not installed"
    }

    private var hostStatusText: String {
        store.installationStatus.nativeHostInstalled ? "Host registered" : "Host missing"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Install on Chrome")
                        .font(.headline)
                    Text("One-click staging for extension + native bridge")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if store.isInstallingExtension {
                    ProgressView()
                        .controlSize(.small)
                        .progressViewStyle(.circular)
                } else {
                    Button {
                        Task { await store.installChromeExtension() }
                    } label: {
                        Text(store.installationStatus.extensionInstalled && store.installationStatus.nativeHostInstalled ? "Reinstall" : "Install")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            if let banner = store.installationBanner {
                HStack(spacing: 10) {
                    Image(systemName: banner.style.systemImageName)
                    Text(banner.message)
                        .font(.callout)
                    Spacer()
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.accentColor.opacity(0.1))
                )
            }

            VStack(alignment: .leading, spacing: 6) {
                statusRow(title: "Extension", value: statusText)
                statusRow(title: "Native Host", value: hostStatusText)
                Text("Chrome may prompt you to enable Zero Six on next launch.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(NSColor.windowBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }

    private func statusRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}

struct SyncInstructionsView: View {
    @Binding var isPresented: Bool
    let instructions: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("How to Sync with Chrome")
                    .font(.title2)
                    .bold()
                Spacer()
                Button("Close") {
                    isPresented = false
                }
            }

            ScrollView {
                Text(instructions)
                    .font(.body.monospaced())
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack {
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Text("Done")
                        .frame(width: 80)
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(minWidth: 520, minHeight: 420)
    }
}
