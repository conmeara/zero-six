import Foundation

struct FeatureToggle: Identifiable, Codable, Hashable {
    let key: String
    var label: String
    var enabled: Bool

    var id: String { key }
}

struct SiteSettings: Identifiable, Codable, Hashable {
    let key: String
    var label: String
    var enabled: Bool
    var features: [FeatureToggle]

    var id: String { key }

    func toDictionary() -> [String: Any] {
        var payload: [String: Any] = ["enabled": enabled]
        for feature in features {
            payload[feature.key] = feature.enabled
        }
        return payload
    }
}

enum SyncBannerStyle {
    case info
    case success
    case warning
    case error

    var systemImageName: String {
        switch self {
        case .info:
            return "info.circle"
        case .success:
            return "checkmark.circle"
        case .warning:
            return "exclamationmark.triangle"
        case .error:
            return "xmark.octagon"
        }
    }
}

struct SyncBanner: Identifiable {
    let id = UUID()
    let message: String
    let style: SyncBannerStyle
}

struct InstallOption: Identifiable {
    enum Kind {
        case chrome
        case safari
        case firefox

        var label: String {
            switch self {
            case .chrome:
                return "Install on Chrome"
            case .safari:
                return "Install on Safari"
            case .firefox:
                return "Install on Firefox"
            }
        }

        var subtitle: String {
            switch self {
            case .chrome:
                return "Manual setup"
            case .safari:
                return "Coming Soon"
            case .firefox:
                return "Coming Soon"
            }
        }

        var iconName: String {
            switch self {
            case .chrome:
                return "globe"
            case .safari:
                return "safari"
            case .firefox:
                return "flame"
            }
        }
    }

    let id = UUID()
    let kind: Kind

    static var chrome: InstallOption { InstallOption(kind: .chrome) }
    static var safari: InstallOption { InstallOption(kind: .safari) }
    static var firefox: InstallOption { InstallOption(kind: .firefox) }
}
