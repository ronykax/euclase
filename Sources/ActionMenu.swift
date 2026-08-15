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
                withAnimation(.easeOut(duration: 0.1)) {
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

            VStack(spacing: 0) {
                ForEach(Array(model.filteredActions.enumerated()), id: \.element.id) { index, action in
                    Text(action.title)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(index == model.actionSelectedIndex ? .primary.opacity(0.1) : Color.clear, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .onTapGesture { model.runAction(action) }
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .frame(width: 240)
        .background(.regularMaterial)
        .background(Color.primary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 6, y: 2)
        .onChange(of: model.actionMenuOpen) {
            // wait for grow-in so the field editor isn't laid out at 5% scale
            if model.actionMenuOpen {
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(100))
                    focused = true
                }
            }
        }
    }
}
