import AppKit

// /Applications, /System/Applications, ~/Applications
func installedApps() -> [Item] {
    [
        "/Applications",
        "/System/Applications",
        NSHomeDirectory() + "/Applications"
    ].flatMap { apps(in: $0) }
}

func apps(in folder: String) -> [Item] {
    guard let enumerator = FileManager.default.enumerator(
        at: URL(fileURLWithPath: folder),
        includingPropertiesForKeys: nil,
        options: [.skipsHiddenFiles, .skipsPackageDescendants]
    ) else { return [] }

    var items: [Item] = []
    for case let url as URL in enumerator {
        guard url.pathExtension == "app" else { continue }
        items.append(Item(
            id: url.path,
            title: url.deletingPathExtension().lastPathComponent,
            icon: NSWorkspace.shared.icon(forFile: url.path),
            path: url.path,
            kind: .app
        ))
    }
    return items
}
