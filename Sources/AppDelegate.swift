import AppKit
import Carbon
import SwiftUI

// borderless windows can't become key unless we say so
final class LauncherPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    override func fieldEditor(_ createFlag: Bool, for object: Any?) -> NSText? {
        let editor = super.fieldEditor(createFlag, for: object)
        (editor as? NSTextView)?.insertionPointColor = .labelColor
        return editor
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    static let shared = AppDelegate()

    let model = Model()
    private var panel: LauncherPanel!
    private var hotKeyRef: EventHotKeyRef?
    private var clickMonitor: Any?
    private var cmdTabMonitor: Any?
    private var appActivateObserver: NSObjectProtocol?

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
        // cmd+tab still reaches us because the panel is key
        cmdTabMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains(.command) && event.keyCode == UInt16(kVK_Tab) {
                self?.hide()
            }
            return event
        }
        appActivateObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            if app?.processIdentifier != ProcessInfo.processInfo.processIdentifier {
                self?.hide()
            }
        }
    }

    func hide() {
        if let clickMonitor {
            NSEvent.removeMonitor(clickMonitor)
            self.clickMonitor = nil
        }
        if let cmdTabMonitor {
            NSEvent.removeMonitor(cmdTabMonitor)
            self.cmdTabMonitor = nil
        }
        if let appActivateObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(appActivateObserver)
            self.appActivateObserver = nil
        }
        model.closeActionMenu()
        panel.orderOut(nil)
    }

    private func buildPanel() {
        panel = LauncherPanel(
            contentRect: NSRect(x: 0, y: 0, width: 620, height: 416),
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
        panel.animationBehavior = .none
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
