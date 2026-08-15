import AppKit
import SwiftUI

struct ActionMenu: View {
    var model: Model
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 0) {
            TextField(
                "Search...",
                text: Binding(
                    get: { model.actionQuery },
                    set: { model.setActionQuery($0) }
                )
            )
            .textFieldStyle(.plain)
            .font(.body)
            .lineLimit(1)
            .padding(16)
            .focused($focused)
            .onKeyPress(.downArrow) {
                model.moveActionSelection(1)
                return .handled
            }
            .onKeyPress(.upArrow) {
                model.moveActionSelection(-1)
                return .handled
            }
            .onKeyPress(.return) {
                model.runSelectedAction()
                return .handled
            }
            .onKeyPress(.escape) {
                withAnimation(.easeOut(duration: 0.15)) {
                    model.closeActionMenu()
                }
                return .handled
            }
            .onKeyPress(keys: ["k"]) { press in
                guard press.modifiers.contains(.command) else { return .ignored }
                model.toggleActionMenu()
                return .handled
            }
            .onKeyPress(keys: ["a"]) { press in
                guard press.modifiers.contains(.command) else { return .ignored }
                NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil)
                return .handled
            }

            ForEach(Array(model.filteredActions.enumerated()), id: \.element.id) { index, action in
                Text(action.title)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(index == model.actionSelectedIndex ? Color.accentColor.opacity(0.3) : Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { model.runAction(action) }
            }
        }
        .frame(width: 240)
        .background(.regularMaterial)
        .background(Color.primary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .onChange(of: model.actionMenuOpen) {
            // wait for grow-in so the field editor isn't laid out at 5% scale
            if model.actionMenuOpen {
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(150))
                    focused = true
                }
            }
        }
    }
}
