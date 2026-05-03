import Foundation

struct Extension {
    let id: String
    let path: String
    let description: String
    let commands: [Command]
}

struct Command {
    let name: String
    let description: String
}

final class ExtensionDiscoveryService {
    private let fileManager: FileManager
    private let extensionsRootURL: URL

    init(
        fileManager: FileManager = .default,
        extensionsRootURL: URL = URL(fileURLWithPath: "/Users/rony/.config/euclase/extensions")
    ) {
        self.fileManager = fileManager
        self.extensionsRootURL = extensionsRootURL
    }

    func discoverExtensions() -> [Extension] {
        var discoveredExtensions: [Extension] = []

        for directoryURL in extensionDirectoryURLs() {
            guard let package = loadPackageJSON(at: directoryURL) else {
                print("Skipping extension at \(directoryURL.path): invalid or missing package.json")
                continue
            }

            let metadata = extractExtensionMetadata(from: package)
            let extensionPath = buildExtensionPath(forExtensionID: metadata.id)
            guard let commands = discoverCommands(
                in: directoryURL,
                commandDescriptionsByName: package.commands
            ) else {
                print("Skipping extension at \(directoryURL.path): invalid command descriptions map")
                continue
            }

            discoveredExtensions.append(
                Extension(
                    id: metadata.id,
                    path: extensionPath,
                    description: metadata.description,
                    commands: commands
                )
            )
        }

        return discoveredExtensions
    }

    private func extensionDirectoryURLs() -> [URL] {
        guard let urls = try? fileManager.contentsOfDirectory(
            at: extensionsRootURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            print("Could not read extensions directory at \(extensionsRootURL.path)")
            return []
        }

        return urls.filter { url in
            (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
        }
    }

    private func loadPackageJSON(at extensionDirectoryURL: URL) -> ExtensionPackageJSON? {
        let packageURL = extensionDirectoryURL.appendingPathComponent("package.json")

        guard fileManager.fileExists(atPath: packageURL.path) else {
            return nil
        }

        guard let data = try? Data(contentsOf: packageURL) else {
            return nil
        }

        return try? JSONDecoder().decode(ExtensionPackageJSON.self, from: data)
    }

    private func extractExtensionMetadata(from package: ExtensionPackageJSON) -> (id: String, description: String) {
        let description = package.description ?? ""
        return (id: package.name, description: description)
    }

    private func discoverCommands(
        in extensionDirectoryURL: URL,
        commandDescriptionsByName: [String: String]
    ) -> [Command]? {
        let commandsDirectoryURL = extensionDirectoryURL.appendingPathComponent("commands", isDirectory: true)

        guard fileManager.fileExists(atPath: commandsDirectoryURL.path) else {
            print("Extension at \(extensionDirectoryURL.path) has no commands directory")
            return nil
        }

        guard let commandFileURLs = try? fileManager.contentsOfDirectory(
            at: commandsDirectoryURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            print("Could not read commands at \(commandsDirectoryURL.path)")
            return nil
        }

        let discoveredCommandNames = commandFileURLs
            .filter { $0.pathExtension == "ts" }
            .compactMap { commandFileURL in
                commandName(from: commandFileURL)
            }
            .sorted()

        let unknownCommands = Set(commandDescriptionsByName.keys).subtracting(Set(discoveredCommandNames))
        guard unknownCommands.isEmpty else {
            print(
                """
                Extension at \(extensionDirectoryURL.path) has descriptions for unknown commands: \
                \(unknownCommands.sorted().joined(separator: ", "))
                """
            )
            return nil
        }

        let commands = discoveredCommandNames.compactMap { commandName -> Command? in
            guard let description = commandDescriptionsByName[commandName] else {
                print("Extension at \(extensionDirectoryURL.path) is missing description for command '\(commandName)'")
                return nil
            }

            let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedDescription.isEmpty else {
                print("Extension at \(extensionDirectoryURL.path) has empty description for command '\(commandName)'")
                return nil
            }

            return Command(name: commandName, description: trimmedDescription)
        }

        guard commands.count == discoveredCommandNames.count else {
            return nil
        }

        return commands
    }

    private func commandName(from commandFileURL: URL) -> String? {
        let name = commandFileURL.deletingPathExtension().lastPathComponent
        return name.isEmpty ? nil : name
    }

    private func buildExtensionPath(forExtensionID extensionID: String) -> String {
        "\(extensionsRootURL.path)/\(extensionID)"
    }
}

private struct ExtensionPackageJSON: Decodable {
    let name: String
    let description: String?
    let commands: [String: String]
}
