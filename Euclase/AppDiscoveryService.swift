import Foundation

struct DiscoveredApp {
    let name: String
    let path: String
}

final class AppDiscoveryService {
    private struct DiscoveryRoot {
        let url: URL
        let isRecursive: Bool
    }

    private let fileManager: FileManager
    private let discoveryRoots: [DiscoveryRoot]

    init(
        fileManager: FileManager = .default,
        discoveryRoots: [URL] = [
            URL(fileURLWithPath: "/Applications"),
            URL(fileURLWithPath: "/System/Applications"),
            URL(fileURLWithPath: "/Users/rony/Applications")
        ],
        recursivelyScannedRootPaths: Set<String> = ["/System/Applications"]
    ) {
        self.fileManager = fileManager
        self.discoveryRoots = discoveryRoots.map { rootURL in
            DiscoveryRoot(
                url: rootURL,
                isRecursive: recursivelyScannedRootPaths.contains(rootURL.path)
            )
        }
    }

    func discoverApps() -> [DiscoveredApp] {
        var discoveredApps: [DiscoveredApp] = []
        var seenPaths = Set<String>()

        for root in discoveryRoots {
            for bundleURL in appBundleURLs(in: root) {
                guard let app = discoveredApp(from: bundleURL) else {
                    continue
                }

                guard seenPaths.insert(app.path).inserted else {
                    continue
                }

                discoveredApps.append(app)
            }
        }

        return discoveredApps
    }

    private func appBundleURLs(in root: DiscoveryRoot) -> [URL] {
        if root.isRecursive {
            return recursivelyDiscoveredAppBundleURLs(in: root.url)
        }

        return topLevelAppBundleURLs(in: root.url)
    }

    private func topLevelAppBundleURLs(in rootURL: URL) -> [URL] {
        guard let urls = try? fileManager.contentsOfDirectory(
            at: rootURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            print("Could not read applications directory at \(rootURL.path)")
            return []
        }

        return urls.filter(isAppBundle)
    }

    private func recursivelyDiscoveredAppBundleURLs(in rootURL: URL) -> [URL] {
        guard let enumerator = fileManager.enumerator(
            at: rootURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles],
            errorHandler: { url, error in
                print("Could not read applications entry at \(url.path): \(error.localizedDescription)")
                return true
            }
        ) else {
            print("Could not enumerate applications directory at \(rootURL.path)")
            return []
        }

        var appBundleURLs: [URL] = []

        for case let url as URL in enumerator {
            guard isAppBundle(url) else {
                continue
            }

            appBundleURLs.append(url)
            enumerator.skipDescendants()
        }

        return appBundleURLs
    }

    private func isAppBundle(_ url: URL) -> Bool {
        guard url.pathExtension == "app" else {
            return false
        }

        return (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
    }

    private func discoveredApp(from bundleURL: URL) -> DiscoveredApp? {
        let name = appName(from: bundleURL)

        guard !name.isEmpty else {
            return nil
        }

        return DiscoveredApp(name: name, path: bundleURL.path)
    }

    private func appName(from bundleURL: URL) -> String {
        bundleURL.deletingPathExtension().lastPathComponent
    }
}
