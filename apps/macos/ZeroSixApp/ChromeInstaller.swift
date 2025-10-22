import Foundation
#if canImport(AppKit)
import AppKit
#endif

struct ChromeInstaller {
    struct InstallationResult: Sendable {
        let success: Bool
        let message: String
    }

    private static let fileManager = FileManager.default
    // Derived from the public key embedded in apps/chrome-extension/manifest.json.
    private static let extensionIdentifier = "kjbjfiodhgmihgdnnbjofjoedjgccdaj"
    // Native messaging host identifier shared with the extension manifest.
    private static let hostName = "app.zerosix.host"

    private static var chromeSupportDirectory: URL {
        fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/Google/Chrome", isDirectory: true)
    }

    private static var externalExtensionsDirectory: URL {
        chromeSupportDirectory.appendingPathComponent("External Extensions", isDirectory: true)
    }

    private static var nativeMessagingDirectory: URL {
        chromeSupportDirectory.appendingPathComponent("NativeMessagingHosts", isDirectory: true)
    }

    private static var zerosixSupportDirectory: URL {
        fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/ZeroSix", isDirectory: true)
    }

    private static var extensionPayloadDirectory: URL {
        zerosixSupportDirectory.appendingPathComponent("ChromeExtension/Payload", isDirectory: true)
    }

    private static var hostRuntimeDirectory: URL {
        zerosixSupportDirectory.appendingPathComponent("Bridge", isDirectory: true)
    }

    private static var hostExecutableURL: URL {
        hostRuntimeDirectory.appendingPathComponent("ZeroSixHost")
    }

    private static var hostManifestURL: URL {
        nativeMessagingDirectory.appendingPathComponent("\(hostName).json")
    }

    private static var externalExtensionManifestURL: URL {
        externalExtensionsDirectory.appendingPathComponent("\(extensionIdentifier).json")
    }

    private static func resourceURL(named name: String, extension fileExtension: String, in bundle: Bundle) -> URL? {
        if let url = bundle.url(forResource: name, withExtension: fileExtension, subdirectory: "ChromeExtension") {
            return url
        }
        return bundle.url(forResource: name, withExtension: fileExtension)
    }

    static func ensureSupportDirectories() throws {
        try fileManager.createDirectory(at: zerosixSupportDirectory, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: extensionPayloadDirectory.deletingLastPathComponent(), withIntermediateDirectories: true)
        try fileManager.createDirectory(at: hostRuntimeDirectory, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: externalExtensionsDirectory, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: nativeMessagingDirectory, withIntermediateDirectories: true)
    }

    static func installExtensionAndHost(from bundle: Bundle = .main) -> InstallationResult {
        do {
            try ensureSupportDirectories()
            try unpackExtension(from: bundle)
            try registerExternalExtension()
            try installNativeHost(from: bundle)
            return InstallationResult(success: true, message: "Chrome extension and native host staged. Restart Chrome to complete installation.")
        } catch {
            return InstallationResult(success: false, message: error.localizedDescription)
        }
    }

    static func installNativeHost(from bundle: Bundle = .main) throws {
        guard let scriptURL = resourceURL(named: "ZeroSixHost", extension: "swift.txt", in: bundle) else {
            throw InstallerError.missingBundleResource("ZeroSixHost.swift.txt")
        }
        let destinationScriptURL = hostExecutableURL.appendingPathExtension("swift")
        if fileManager.fileExists(atPath: destinationScriptURL.path) {
            try fileManager.removeItem(at: destinationScriptURL)
        }
        try fileManager.copyItem(at: scriptURL, to: destinationScriptURL)
        try markExecutable(at: destinationScriptURL)

        // Symlink executable without .swift extension for convenience.
        if fileManager.fileExists(atPath: hostExecutableURL.path) {
            try fileManager.removeItem(at: hostExecutableURL)
        }
        try fileManager.createSymbolicLink(at: hostExecutableURL, withDestinationURL: destinationScriptURL)

        let manifest = NativeHostManifest(
            name: hostName,
            description: "Zero Six native messaging host",
            path: hostExecutableURL.path,
            allowedOrigins: ["chrome-extension://\(extensionIdentifier)/"]
        )
        let manifestData = try manifest.encode()
        try manifestData.write(to: hostManifestURL, options: [.atomic])
    }

    static func registerExternalExtension() throws {
        let manifest = ExternalExtensionManifest(externalUnpackedDir: extensionPayloadDirectory.path)
        let data = try manifest.encode()
        try data.write(to: externalExtensionManifestURL, options: [.atomic])
    }

    static func unpackExtension(from bundle: Bundle) throws {
        guard let archiveURL = resourceURL(named: "zero-six-extension", extension: "zip", in: bundle) else {
            throw InstallerError.missingBundleResource("zero-six-extension.zip")
        }

        if fileManager.fileExists(atPath: extensionPayloadDirectory.path) {
            try fileManager.removeItem(at: extensionPayloadDirectory)
        }
        try fileManager.createDirectory(at: extensionPayloadDirectory, withIntermediateDirectories: true)

        let task = Process()
        task.launchPath = "/usr/bin/unzip"
        task.arguments = ["-o", archiveURL.path, "-d", extensionPayloadDirectory.path]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        try task.run()
        task.waitUntilExit()

        if task.terminationStatus != 0 {
            let errorData = pipe.fileHandleForReading.readDataToEndOfFile()
            let message = String(data: errorData, encoding: .utf8) ?? "Unknown unzip error"
            throw InstallerError.unzipFailed(message)
        }
    }

    static func extensionIsInstalled() -> Bool {
        fileManager.fileExists(atPath: extensionPayloadDirectory.path) && fileManager.fileExists(atPath: externalExtensionManifestURL.path)
    }

    static func nativeHostIsInstalled() -> Bool {
        fileManager.fileExists(atPath: hostExecutableURL.path) && fileManager.fileExists(atPath: hostManifestURL.path)
    }

    static func installationStatus() -> InstallationStatus {
        InstallationStatus(
            extensionInstalled: extensionIsInstalled(),
            nativeHostInstalled: nativeHostIsInstalled(),
            externalExtensionManifestURL: externalExtensionManifestURL.path,
            nativeHostManifestURL: hostManifestURL.path
        )
    }

    private static func markExecutable(at url: URL) throws {
        var attributes = try fileManager.attributesOfItem(atPath: url.path)
        if let posixPermissions = attributes[.posixPermissions] as? NSNumber {
            let newPermissions = posixPermissions.uint16Value | UInt16(strtoul("0111", nil, 8))
            attributes[.posixPermissions] = NSNumber(value: newPermissions)
            try fileManager.setAttributes(attributes, ofItemAtPath: url.path)
        } else {
            try fileManager.setAttributes([.posixPermissions: NSNumber(value: Int16(0o755))], ofItemAtPath: url.path)
        }
    }
}

extension ChromeInstaller {
    enum InstallerError: LocalizedError {
        case missingBundleResource(String)
        case unzipFailed(String)

        var errorDescription: String? {
            switch self {
            case .missingBundleResource(let name):
                return "Missing bundled resource: \(name)"
            case .unzipFailed(let message):
                return "Unable to unpack extension: \(message)"
            }
        }
    }

    struct InstallationStatus: Codable, Hashable {
        let extensionInstalled: Bool
        let nativeHostInstalled: Bool
        let externalExtensionManifestURL: String
        let nativeHostManifestURL: String
    }

    struct NativeHostManifest: Encodable {
        let name: String
        let description: String
        let path: String
        let type: String = "stdio"
        let allowed_origins: [String]

        init(name: String, description: String, path: String, allowedOrigins: [String]) {
            self.name = name
            self.description = description
            self.path = path
            self.allowed_origins = allowedOrigins
        }

        func encode() throws -> Data {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return try encoder.encode(self)
        }
    }

    struct ExternalExtensionManifest: Encodable {
        let external_unpacked_dir: String
        let external_version: String
        let initially_enabled: Bool

        init(externalUnpackedDir: String, version: String = "0.1.0", enabled: Bool = true) {
            self.external_unpacked_dir = externalUnpackedDir
            self.external_version = version
            self.initially_enabled = enabled
        }

        func encode() throws -> Data {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return try encoder.encode(self)
        }
    }
}
