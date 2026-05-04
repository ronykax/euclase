import SwiftUI
import Combine

enum LauncherView {
    case root
    case list(items: [String])   // expand fields as needed
    case grid(items: [String])
}

class ViewController: ObservableObject {
    static let shared = ViewController()

    @Published private(set) var current: LauncherView = .root
    private var stack: [LauncherView] = [.root]

    func showRoot() {
        stack = [.root]
        current = .root
    }

    func showList(items: [String]) {
        let view = LauncherView.list(items: items)
        stack.append(view)
        current = view
    }

    func showGrid(items: [String]) {
        let view = LauncherView.grid(items: items)
        stack.append(view)
        current = view
    }

    func goBack() {
        guard stack.count > 1 else { return }
        stack.removeLast()
        current = stack.last!
    }
}
