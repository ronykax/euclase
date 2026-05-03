import SwiftUI

struct ContentView: View {
    @State var buttonText1 = "cow say hello world"
    @State var buttonText2 = "cow say hello world"
    
    var body: some View {
        VStack {
            TextInputView()
            
            // here's where I want all the buttons for all the commands to be
            Button(buttonText1) {
                CommandRunner.run(
                    file: "/Users/rony/.config/euclase/extensions/cowsay/index.ts"
                ) { message in
                    // TEMP: Per-message print timing instrumentation.
                    let startTime = DispatchTime.now().uptimeNanoseconds
                    defer {
                        let endTime = DispatchTime.now().uptimeNanoseconds
                        let elapsedMs = Double(endTime - startTime) / 1_000_000
                        buttonText1 = "took \(elapsedMs) ms"
                        print("TEMP print timing: \(elapsedMs) ms")
                    }

                    guard
                        let data = message.data(using: .utf8),
                        let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let method = payload["method"] as? String,
                        method == "print",
                        let params = payload["params"]
                    else {
                        print(message)
                        return
                    }
                    
                    print(params)
                }
            }
            Button(buttonText2) {
                CommandRunner.run(
                    file: "/Users/rony/.config/euclase/extensions/cowsay/index2.ts"
                ) { message in
                    guard
                        let data = message.data(using: .utf8),
                        let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let method = payload["method"] as? String,
                        method == "print",
                        let params = payload["params"]
                    else {
                        print(message)
                        return
                    }
                    
                    print(params)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
