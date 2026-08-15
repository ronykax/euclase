import AppKit

@main
@MainActor
enum Euclase {
    static func main() {
        let app = NSApplication.shared
        app.delegate = AppDelegate.shared
        app.setActivationPolicy(.accessory) // no dock icon
        app.run()
    }
}
