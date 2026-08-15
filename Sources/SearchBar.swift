import AppKit
import SwiftUI

struct SearchBar: View {
    var model: Model
    @FocusState private var focused: Bool

    var body: some View {
        TextField(
            "Search for apps and commands...",
            text: Binding(
                get: { model.query },
                set: { model.setQuery($0) }
            )
        )
        .textFieldStyle(.plain)
        .font(.body)
        .padding(16)
        .focused($focused)
        .onKeyPress(.downArrow) {
            model.moveSelection(1)
            return .handled
        }
        .onKeyPress(.upArrow) {
            model.moveSelection(-1)
            return .handled
        }
        .onKeyPress(keys: [.return]) { press in
            if press.modifiers.contains(.command) {
                model.revealSelected()
            } else {
                model.runSelected()
            }
            return .handled
        }
        .onKeyPress(.escape) {
            model.hide()
            return .handled
        }
        .onKeyPress(.delete) {
            if model.query.isEmpty {
                model.pop()
                return .handled
            }
            return .ignored
        }
        .onKeyPress(keys: ["a"]) { press in
            guard press.modifiers.contains(.command) else { return .ignored }
            NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil)
            return .handled
        }
        .task(id: model.showCount) {
            focused = true
        }
    }
}
