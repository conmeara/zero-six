import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

struct SiteSettingsCard: View {
    @Binding var site: SiteSettings
    var onChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            Divider()
            VStack(spacing: 8) {
                ForEach($site.features) { $feature in
                    Toggle(isOn: binding(for: $feature)) {
                        Text(feature.label)
                            .font(.body)
                    }
                    .toggleStyle(.switch)
                    .disabled(!site.enabled)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
        )
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(site.label)
                    .font(.title3)
                    .bold()
                if !site.enabled {
                    Text("Disabled")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Toggle(isOn: $site.enabled) {
                Text(site.enabled ? "Enabled" : "Disabled")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .toggleStyle(.switch)
            .onChange(of: site.enabled) { _ in
                onChange()
            }
        }
    }

    private func binding(for feature: Binding<FeatureToggle>) -> Binding<Bool> {
        Binding(
            get: { feature.wrappedValue.enabled },
            set: { newValue in
                feature.wrappedValue.enabled = newValue
                onChange()
            }
        )
    }
}

struct InstallOptionButton: View {
    let option: InstallOption
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: iconGradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 40, height: 40)
                    Image(systemName: option.kind.iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.kind.label)
                        .font(.headline)
                    Text(option.kind.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(NSColor.windowBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var iconGradient: [Color] {
        switch option.kind {
        case .chrome:
            return [Color(red: 0.98, green: 0.29, blue: 0.22), Color(red: 0.21, green: 0.64, blue: 0.27)]
        case .safari:
            return [Color(red: 0.14, green: 0.53, blue: 0.98), Color(red: 0.08, green: 0.29, blue: 0.62)]
        case .firefox:
            return [Color(red: 0.98, green: 0.35, blue: 0.18), Color(red: 0.85, green: 0.18, blue: 0.49)]
        }
    }
}

struct SyncStatusView: View {
    @EnvironmentObject private var store: SettingsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let banner = store.banner {
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: banner.style.systemImageName)
                        .foregroundStyle(iconColor(for: banner.style))
                    Text(banner.message)
                        .font(.callout)
                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(iconColor(for: banner.style).opacity(0.12))
                )
            }

            HStack(spacing: 12) {
                Image(systemName: store.hasUnsyncedChanges ? "exclamationmark.circle" : "checkmark.circle")
                    .foregroundStyle(store.hasUnsyncedChanges ? Color.orange : Color.green)
                VStack(alignment: .leading, spacing: 2) {
                    if store.hasUnsyncedChanges {
                        Text("Unsynced changes")
                            .font(.subheadline)
                            .bold()
                        Text("Copy the settings JSON and paste it in your browser extension to sync.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if let lastSynced = store.lastSyncedAt {
                        Text("Synced to clipboard")
                            .font(.subheadline)
                            .bold()
                        Text("Last exported \(lastSynced.formatted(date: .abbreviated, time: .shortened)).")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Ready to sync")
                            .font(.subheadline)
                            .bold()
                        Text("Copy the settings JSON to apply changes in the extension.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(NSColor.controlBackgroundColor))
            )
        }
    }

    private func iconColor(for style: SyncBannerStyle) -> Color {
        switch style {
        case .info:
            return Color.blue
        case .success:
            return Color.green
        case .warning:
            return Color.orange
        case .error:
            return Color.red
        }
    }
}
