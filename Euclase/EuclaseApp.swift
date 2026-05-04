import SwiftUI
import HotKey
import AppKit

@main
struct EuclaseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

final class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    static weak var shared: AppDelegate?
    var panel: FloatingPanel!
    var hotKey: HotKey!

    func applicationDidFinishLaunching(_ notification: Notification) {
        Self.shared = self
        panel = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.level = .statusBar
        panel.backgroundColor = .clear
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.hidesOnDeactivate = false
        panel.isFloatingPanel = true
        panel.isMovableByWindowBackground = true
        panel.animationBehavior = .none
        panel.contentView = NSHostingView(rootView: ContentView())
        panel.center()

        hotKey = HotKey(key: .space, modifiers: [.command])
        hotKey.keyDownHandler = { [weak self] in
            self?.togglePanel()
        }
    }

    func togglePanel() {
        if panel.isVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }
    
    func hidePanel() {
        panel.orderOut(nil)
    }
    
    func showPanel() {
        panel.orderFrontRegardless()
        panel.makeKey()
    }
}
