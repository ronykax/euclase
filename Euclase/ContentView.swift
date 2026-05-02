import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var registry: ExtensionRegistry
    @State private var inputText = ""

    private var filteredCommands: [ExtensionCommand] {
        let query = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return registry.commands }

        return registry.commands.filter { command in
            command.commandID.localizedCaseInsensitiveContains(query)
                || command.description.localizedCaseInsensitiveContains(query)
                || command.extensionName.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            MainInputView(
                text: $inputText,
                iconSystemName: "magnifyingglass",
                placeholder: "Search for apps and commands..."
            )
            
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if filteredCommands.isEmpty {
                        Text("No commands found")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(Array(filteredCommands.enumerated()), id: \.element.id) { index, command in
                            Button {
                                JavaScriptCommandRunner.run(command: command)
                            } label: {
                                CommandItemView(
                                    selected: index == 0,
                                    title: command.commandID,
                                    description: command.description,
                                    starred: false
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
