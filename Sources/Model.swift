import AppKit
import Observation

// one screen on the view stack. root starts as the only screen.
struct Screen {
    var query = ""
    var selectedIndex = 0
}

@MainActor
@Observable
final class Model {
    var stack = [Screen()]
    var apps: [Item] = []
    var files: [Item] = []
    var showCount = 0
    var onHide: () -> Void = {}

    let fileSearch = FileSearch()

    init() {
        apps = installedApps()
        fileSearch.onResults = { [weak self] items in
            self?.files = items
        }
    }

    var query: String {
        stack[stack.count - 1].query
    }

    var selectedIndex: Int {
        stack[stack.count - 1].selectedIndex
    }

    var items: [Item] {
        var all = apps + builtInCommands()
        if !query.isEmpty {
            all += files
        }
        return ranked(all, query: query)
    }

    func setQuery(_ text: String) {
        stack[stack.count - 1].query = text
        stack[stack.count - 1].selectedIndex = 0
        fileSearch.search(text)
    }

    func setSelected(_ index: Int) {
        stack[stack.count - 1].selectedIndex = index
    }

    func moveSelection(_ delta: Int) {
        let count = items.count
        guard count > 0 else { return }
        stack[stack.count - 1].selectedIndex = min(max(selectedIndex + delta, 0), count - 1)
    }

    func push(_ screen: Screen = Screen()) {
        stack.append(screen)
    }

    func pop() {
        if stack.count > 1 {
            stack.removeLast()
        } else {
            hide()
        }
    }

    func hide() {
        onHide()
    }

    func reset() {
        stack = [Screen()]
        files = []
        fileSearch.search("")
        showCount += 1
    }

    func runSelected() {
        let list = items
        guard list.indices.contains(selectedIndex) else { return }
        run(list[selectedIndex])
    }

    func revealSelected() {
        let list = items
        guard list.indices.contains(selectedIndex), let path = list[selectedIndex].path else { return }
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: path)])
        hide()
    }

    func run(_ item: Item) {
        switch item.kind {
        case .app, .file:
            if let path = item.path {
                NSWorkspace.shared.open(URL(fileURLWithPath: path))
            }
            hide()
        case .command:
            runCommand(item.id)
        }
    }
}
