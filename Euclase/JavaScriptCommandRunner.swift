import Foundation
import JavaScriptCore

enum JavaScriptCommandRunner {
    private static let executionQueue = DispatchQueue(
        label: "Euclase.JavaScriptCommandRunner",
        qos: .userInitiated
    )

    static func run(command: ExtensionCommand) {
        executionQueue.async {
            execute(command: command)
        }
    }

    private static func execute(command: ExtensionCommand) {
        guard let context = JSContext() else { return }

        context.exceptionHandler = { _, exception in
            // TODO: Surface script exceptions in the UI.
            if let message = exception?.toString() {
                print("JavaScript error in \(command.id): \(message)")
            }
        }

        let printBridge: @convention(block) (String) -> Void = { message in
            print(message)
        }
        context.setObject(printBridge, forKeyedSubscript: "Print" as NSString)

        do {
            let script = try String(contentsOf: command.scriptURL, encoding: .utf8)
            _ = context.evaluateScript(script, withSourceURL: command.scriptURL)
        } catch {
            // TODO: Surface script file read errors in the UI.
            print("Failed to read script for \(command.id): \(error)")
        }
    }
}
