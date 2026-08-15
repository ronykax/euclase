import AppKit

// spotlight search for files and folders
@MainActor
final class FileSearch: NSObject {
    var onResults: ([Item]) -> Void = { _ in }

    private let query = NSMetadataQuery()
    private var observer: NSObjectProtocol?

    override init() {
        super.init()
        query.searchScopes = [NSMetadataQueryLocalComputerScope]
        observer = NotificationCenter.default.addObserver(
            forName: .NSMetadataQueryDidFinishGathering,
            object: query,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.takeResults()
            }
        }
    }

    func search(_ text: String) {
        if query.isStarted {
            query.stop()
        }
        guard !text.isEmpty else {
            onResults([])
            return
        }
        query.predicate = NSPredicate(
            format: "%K CONTAINS[cd] %@",
            NSMetadataItemFSNameKey,
            text
        )
        query.start()
    }

    private func takeResults() {
        // ignore leftover notifications from a search we already stopped
        guard query.isStarted else { return }
        var items: [Item] = []
        for i in 0..<query.resultCount {
            if items.count >= 40 { break }
            guard let md = query.result(at: i) as? NSMetadataItem else { continue }
            guard let path = md.value(forAttribute: NSMetadataItemPathKey) as? String else { continue }
            if path.hasSuffix(".app") { continue }
            items.append(Item(
                id: path,
                title: URL(fileURLWithPath: path).lastPathComponent,
                icon: NSWorkspace.shared.icon(forFile: path),
                path: path,
                kind: .file
            ))
        }
        query.stop()
        onResults(items)
    }
}
