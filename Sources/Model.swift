import AppKit
import Observation
import SwiftUI

// one screen on the view stack. root starts as the only screen.
struct Screen {
    var query = ""
    var selectedIndex = 0
}

struct Action: Identifiable {
    var id: String
    var title: String
}

func actions(for item: Item) -> [Action] {
    switch item.kind {
    case .app:
        [
            Action(id: "open", title: "Open"),
            Action(id: "reveal", title: "Reveal in Finder"),
        ]
    case .file:
        [
            Action(id: "open", title: "Open"),
            Action(id: "reveal", title: "Reveal in Finder"),
            Action(id: "trash", title: "Move to Trash"),
        ]
    case .command:
        [
            Action(id: "run", title: "Run"),
        ]
    }
}

@MainActor
@Observable
final class Model {
    var stack = [Screen()]
    var apps: [Item] = []
    var files: [Item] = []
    var showCount = 0
    var onHide: () -> Void = {}
    var actionMenuOpen = false
    var actionQuery = ""
    var actionSelectedIndex = 0

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

    var selectedItem: Item? {
        let list = items
        guard list.indices.contains(selectedIndex) else { return nil }
        return list[selectedIndex]
    }

    var filteredActions: [Action] {
        guard let item = selectedItem else { return [] }
        let all = actions(for: item)
        if actionQuery.isEmpty { return all }
        return all.filter { $0.title.localizedCaseInsensitiveContains(actionQuery) }
    }

    func setQuery(_ text: String) {
        guard text != query else { return }
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
        closeActionMenu()
        showCount += 1
    }

    func toggleActionMenu() {
        withAnimation(.easeOut(duration: 0.1)) {
            if actionMenuOpen {
                closeActionMenu()
                return
            }
            guard selectedItem != nil else { return }
            actionQuery = ""
            actionSelectedIndex = 0
            actionMenuOpen = true
        }
    }

    func closeActionMenu() {
        actionMenuOpen = false
        actionQuery = ""
        actionSelectedIndex = 0
    }

    func setActionQuery(_ text: String) {
        actionQuery = text
        actionSelectedIndex = 0
    }

    func moveActionSelection(_ delta: Int) {
        let count = filteredActions.count
        guard count > 0 else { return }
        actionSelectedIndex = min(max(actionSelectedIndex + delta, 0), count - 1)
    }

    func runSelectedAction() {
        let list = filteredActions
        guard list.indices.contains(actionSelectedIndex) else { return }
        runAction(list[actionSelectedIndex])
    }

    func runAction(_ action: Action) {
        if action.id == "reveal" {
            revealSelected()
        } else if action.id == "trash" {
            trashSelected()
        } else {
            runSelected()
        }
    }

    func trashSelected() {
        guard let path = selectedItem?.path else { return }
        try? FileManager.default.trashItem(at: URL(fileURLWithPath: path), resultingItemURL: nil)
        hide()
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
