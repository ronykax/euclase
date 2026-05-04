import Foundation

class CommandRunner {
    private static let bunExecutableURL = URL(fileURLWithPath: "/Users/rony/.bun/bin/bun")

    static func bunProcess(arguments: [String]) -> Process {
        let process = Process()
        process.executableURL = bunExecutableURL
        process.arguments = arguments
        process.qualityOfService = .userInitiated
        return process
    }

    static func run(file: String, onMessage: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let stdout = Pipe()
            let stderr = Pipe()
            let process = bunProcess(arguments: [file])
            let streamQueue = DispatchQueue(label: "euclase.command-runner.stream")
            var stdoutBuffer = ""
            var stderrBuffer = ""

            process.standardOutput = stdout
            process.standardError = stderr

            func consumeLines(
                from buffer: inout String,
                append chunk: String,
                onLine: (String) -> Void
            ) {
                buffer += chunk

                while let newlineRange = buffer.range(of: "\n") {
                    let line = String(buffer[..<newlineRange.lowerBound])
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    buffer.removeSubrange(...newlineRange.lowerBound)

                    if !line.isEmpty {
                        onLine(line)
                    }
                }
            }

            stdout.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                guard !data.isEmpty, let chunk = String(data: data, encoding: .utf8) else {
                    return
                }

                streamQueue.async {
                    consumeLines(from: &stdoutBuffer, append: chunk) { line in
                        DispatchQueue.main.async {
                            onMessage(line)
                        }
                    }
                }
            }

            stderr.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                guard !data.isEmpty, let chunk = String(data: data, encoding: .utf8) else {
                    return
                }

                streamQueue.async {
                    consumeLines(from: &stderrBuffer, append: chunk) { line in
                        print("Command stderr: \(line)")
                    }
                }
            }

            process.terminationHandler = { _ in
                stdout.fileHandleForReading.readabilityHandler = nil
                stderr.fileHandleForReading.readabilityHandler = nil

                streamQueue.async {
                    let remainingStdout = stdoutBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !remainingStdout.isEmpty {
                        DispatchQueue.main.async {
                            onMessage(remainingStdout)
                        }
                    }

                    let remainingStderr = stderrBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !remainingStderr.isEmpty {
                        print("Command stderr: \(remainingStderr)")
                    }
                }
            }

            do {
                try process.run()
                process.waitUntilExit()
            } catch {
                print("Failed to run process: \(error)")
                stdout.fileHandleForReading.readabilityHandler = nil
                stderr.fileHandleForReading.readabilityHandler = nil
                return
            }
        }
    }
}
