import AppKit

func builtInCommands() -> [Item] {
    [
        Item(
            id: "command:quit",
            title: "Quit Euclase",
            icon: NSImage(systemSymbolName: "power", accessibilityDescription: nil) ?? NSImage(),
            path: nil,
            kind: .command,
            description: "Quit the application"
        )
    ]
}

@MainActor
func runCommand(_ id: String) {
    if id == "command:quit" {
        NSApp.terminate(nil)
    }
}
