import AppKit
import SwiftUI

struct SearchBar: View {
    var model: Model
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: NSImage(systemSymbolName: "magnifyingglass", accessibilityDescription: nil) ?? NSImage())
                .resizable()
                .scaledToFit()
                .foregroundStyle(.secondary)
                .padding(12.5 * 40 / 128)
                .frame(width: 36, height: 36)
                .frame(width: 40, height: 40)
            TextField(
                "Search for apps and commands...",
                text: Binding(
                    get: { model.query },
                    set: { model.setQuery($0) }
                )
            )
            .textFieldStyle(.plain)
            .font(.title)
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
                if model.actionMenuOpen {
                    withAnimation(.easeOut(duration: 0.1)) {
                        model.closeActionMenu()
                    }
                } else {
                    model.hide()
                }
                return .handled
            }
            .onKeyPress(keys: ["k"]) { press in
                guard press.modifiers.contains(.command) else { return .ignored }
                model.toggleActionMenu()
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
            .onChange(of: model.actionMenuOpen) {
                if !model.actionMenuOpen { focused = true }
            }
            .task(id: model.showCount) {
                focused = true
            }
        }
        .padding(16)
    }
}
