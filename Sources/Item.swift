import AppKit

struct Item: Identifiable {
    var id: String
    var title: String
    var icon: NSImage
    var path: String?
    var kind: Kind
    var description: String? = nil

    enum Kind {
        case app
        case file
        case command
    }

    var subtitle: String {
        if let description { return description }
        guard let path else { return "" }
        return URL(fileURLWithPath: path)
            .deletingLastPathComponent()
            .path
            .replacingOccurrences(of: NSHomeDirectory(), with: "~")
    }
}

func ranked(_ items: [Item], query: String) -> [Item] {
    if query.isEmpty {
        return items.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    let needle = query.lowercased()
    return items
        .filter { $0.title.lowercased().contains(needle) }
        .sorted { a, b in
            let aPrefix = a.title.lowercased().hasPrefix(needle)
            let bPrefix = b.title.lowercased().hasPrefix(needle)
            if aPrefix != bPrefix { return aPrefix }
            return a.title.localizedCaseInsensitiveCompare(b.title) == .orderedAscending
        }
}
