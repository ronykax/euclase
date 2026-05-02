import Foundation
import Combine

struct ExtensionManifest: Decodable {
    let name: String
    let version: String
    let description: String?
    let author: String?
    let icon: String?
    let commands: [ManifestCommand]
}

struct ManifestCommand: Decodable {
    let id: String
    let description: String
}

struct ExtensionCommand: Identifiable {
    let id: String
    let extensionName: String
    let commandID: String
    let description: String
    let scriptURL: URL

    var scriptPath: String { scriptURL.path }
}

struct ExtensionRecord: Identifiable {
    let id: String
    let manifest: ExtensionManifest
    let commands: [ExtensionCommand]
}

@MainActor
final class ExtensionRegistry: ObservableObject {
    @Published private(set) var extensions: [ExtensionRecord] = []
    @Published private(set) var commands: [ExtensionCommand] = []

    func reloadFromDisk() {
        let discovered = ExtensionLoader.discoverExtensions()
        extensions = discovered.sorted { $0.manifest.name.localizedCaseInsensitiveCompare($1.manifest.name) == .orderedAscending }
        commands = discovered
            .flatMap(\.commands)
            .sorted { $0.commandID.localizedCaseInsensitiveCompare($1.commandID) == .orderedAscending }
        
//        print("all commands: \(commands)")
    }
}

enum ExtensionLoader {
    static func discoverExtensions() -> [ExtensionRecord] {
        let rootURL = extensionRootURL()
        createDirectoryIfNeeded(at: rootURL)

        let fileManager = FileManager.default
        guard let folderURLs = try? fileManager.contentsOfDirectory(
            at: rootURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return folderURLs.compactMap { folderURL in
            guard isDirectory(folderURL) else { return nil }
            let extensionName = folderURL.lastPathComponent
            let manifestURL = folderURL.appendingPathComponent("manifest.json")
            let commandsURL = folderURL.appendingPathComponent("commands", isDirectory: true)

            guard
                let manifestData = try? Data(contentsOf: manifestURL),
                let manifest = try? JSONDecoder().decode(ExtensionManifest.self, from: manifestData)
            else {
                // TODO: Surface invalid/missing manifest errors in Settings.
                return nil
            }

            let commands = loadCommands(
                from: commandsURL,
                extensionName: extensionName,
                manifestCommands: manifest.commands
            )
            return ExtensionRecord(
                id: extensionName,
                manifest: manifest,
                commands: commands
            )
        }
    }

    static func extensionRootURL() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let baseURL = appSupport ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Application Support", isDirectory: true)
        return baseURL
            .appendingPathComponent("Euclase", isDirectory: true)
            .appendingPathComponent("extensions", isDirectory: true)
    }

    private static func loadCommands(
        from commandsURL: URL,
        extensionName: String,
        manifestCommands: [ManifestCommand]
    ) -> [ExtensionCommand] {
        let fileManager = FileManager.default
        guard let fileURLs = try? fileManager.contentsOfDirectory(
            at: commandsURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var manifestByID: [String: ManifestCommand] = [:]
        var duplicateManifestIDs = Set<String>()
        for command in manifestCommands {
            if manifestByID[command.id] != nil {
                duplicateManifestIDs.insert(command.id)
                continue
            }
            manifestByID[command.id] = command
        }
        for duplicateID in duplicateManifestIDs.sorted() {
            print("Duplicate manifest command id '\(duplicateID)' in extension '\(extensionName)'.")
        }

        let scriptFiles = fileURLs
            .filter { isJavaScriptCommandFile($0) }
            .sorted { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }

        var discoveredScriptIDs = Set<String>()
        var commands: [ExtensionCommand] = []

        for fileURL in scriptFiles {
            let commandID = fileURL.deletingPathExtension().lastPathComponent
            discoveredScriptIDs.insert(commandID)

            guard let manifestCommand = manifestByID[commandID] else {
                print("Skipping command \(extensionName).\(commandID): missing command metadata in manifest.json.")
                continue
            }

            let description = manifestCommand.description.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !description.isEmpty else {
                print("Skipping command \(extensionName).\(commandID): manifest command description is empty.")
                continue
            }

            commands.append(
                ExtensionCommand(
                    id: "\(extensionName).\(commandID)",
                    extensionName: extensionName,
                    commandID: commandID,
                    description: description,
                    scriptURL: fileURL
                )
            )
        }

        let missingScriptIDs = Set(manifestByID.keys).subtracting(discoveredScriptIDs)
        for missingID in missingScriptIDs.sorted() {
            print("Manifest command \(extensionName).\(missingID) has no matching script in commands/.")
        }

        return commands
    }

    private static func isJavaScriptCommandFile(_ url: URL) -> Bool {
        url.pathExtension.lowercased() == "js"
    }

    private static func isDirectory(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
    }

    private static func createDirectoryIfNeeded(at url: URL) {
        if FileManager.default.fileExists(atPath: url.path) { return }
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
}
