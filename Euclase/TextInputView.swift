import SwiftUI

struct TextInputView: View {
    @Binding var query: String
    var placeholder: String
    var onEscape: () -> Void = {}
    var onUpArrow: () -> Void = {}
    var onDownArrow: () -> Void = {}
    var onLeftArrow: () -> Void = {}
    var onRightArrow: () -> Void = {}
    var onDelete: () -> Void = {}
    var onReturn: () -> Void = {}

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .frame(width: 24, height: 24)
                .font(.title3)
                .foregroundStyle(.secondary)
            TextField(placeholder, text: $query)
                .textFieldStyle(.plain)
                .font(.title3)
                .onExitCommand {
                    onEscape()
                }
                .onKeyPress(.upArrow) {
                    onUpArrow()
                    return .handled
                }
                .onKeyPress(.downArrow) {
                    onDownArrow()
                    return .handled
                }
                .onKeyPress(.leftArrow) {
                    onLeftArrow()
                    return .handled
                }
                .onKeyPress(.rightArrow) {
                    onRightArrow()
                    return .handled
                }
                .onDeleteCommand {
                    print("delete")
                    onDelete()
                }
                .onSubmit {
                    onReturn()
                }
        }
        .padding()
    }
}
