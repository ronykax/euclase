import AppKit
import Carbon
import SwiftUI

// borderless windows can't become key unless we say so
final class LauncherPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    static let shared = AppDelegate()

    let model = Model()
    private var panel: LauncherPanel!
    private var hotKeyRef: EventHotKeyRef?
    private var clickMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        model.onHide = { [weak self] in
            self?.hide()
        }
        buildPanel()
        registerHotKey() // option+space
    }

    func toggle() {
        if panel.isVisible {
            hide()
        } else {
            show()
        }
    }

    func show() {
        model.reset()
        panel.center()
        panel.orderFrontRegardless()
        panel.makeKey()
        clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.hide()
        }
    }

    func hide() {
        if let clickMonitor {
            NSEvent.removeMonitor(clickMonitor)
            self.clickMonitor = nil
        }
        panel.orderOut(nil)
    }

    private func buildPanel() {
        panel = LauncherPanel(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.level = .floating
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentView = NSHostingView(rootView: LauncherView(model: model))
    }

    private func registerHotKey() {
        var spec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        InstallEventHandler(
            GetApplicationEventTarget(),
            hotKeyPressed,
            1,
            &spec,
            nil,
            nil
        )
        RegisterEventHotKey(
            UInt32(kVK_Space),
            UInt32(optionKey),
            EventHotKeyID(signature: 0x4555434C, id: 1),
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }
}

private func hotKeyPressed(
    _ next: EventHandlerCallRef?,
    _ event: EventRef?,
    _ userData: UnsafeMutableRawPointer?
) -> OSStatus {
    Task { @MainActor in
        AppDelegate.shared.toggle()
    }
    return noErr
}
