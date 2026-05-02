import AppKit
import Carbon
import SwiftUI

final class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

final class PanelController {
    private static let panelIdentifier = NSUserInterfaceItemIdentifier("EuclaseFloatingPanel")

    private let panel: FloatingPanel
    private let registry: ExtensionRegistry
    private let hotKeyMonitor = GlobalHotKeyMonitor()
    private var notificationObservers: [NSObjectProtocol] = []

    init(registry: ExtensionRegistry) {
        self.registry = registry

        panel = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: 550, height: 360),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )

        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.animationBehavior = .none
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.fullScreenAuxiliary, .transient]
        panel.identifier = Self.panelIdentifier
        panel.center()

        let hostingView = NSHostingView(rootView: ContentView().environmentObject(registry))
        panel.contentView = hostingView

        installFocusObservers()
    }

    deinit {
        removeFocusObservers()
        hotKeyMonitor.stop()
    }

    func start() {
        let didStart = hotKeyMonitor.start(
            keyCode: UInt32(kVK_Space),
            modifiers: UInt32(optionKey | cmdKey)
        ) { [weak self] in
            self?.toggle()
        }

        #if DEBUG
        if !didStart {
            print("Panel hotkey monitor failed to start")
        }
        #endif
    }

    private func toggle() {
        panel.isVisible ? hidePanel() : showPanel()
    }

    private func showPanel() {
        panel.orderFrontRegardless()
        panel.makeKey()
        restorePrimaryInputFocusIfNeeded()
    }

    private func hidePanel() {
        panel.orderOut(nil)
    }

    private func installFocusObservers() {
        let notificationCenter = NotificationCenter.default
        let workspaceCenter = NSWorkspace.shared.notificationCenter

        let didBecomeKeyObserver = notificationCenter.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: panel,
            queue: .main
        ) { [weak self] _ in
            self?.restorePrimaryInputFocusIfNeeded()
        }

        let activeSpaceObserver = workspaceCenter.addObserver(
            forName: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self, self.panel.isVisible else { return }
            self.panel.orderFrontRegardless()
            self.panel.makeKey()
            self.restorePrimaryInputFocusIfNeeded()
        }

        notificationObservers.append(didBecomeKeyObserver)
        notificationObservers.append(activeSpaceObserver)
    }

    private func removeFocusObservers() {
        let notificationCenter = NotificationCenter.default
        let workspaceCenter = NSWorkspace.shared.notificationCenter

        for observer in notificationObservers {
            notificationCenter.removeObserver(observer)
            workspaceCenter.removeObserver(observer)
        }
        notificationObservers.removeAll()
    }

    private func restorePrimaryInputFocusIfNeeded() {
        DispatchQueue.main.async { [weak self] in
            self?.focusFirstTextInput()
        }
    }

    private func focusFirstTextInput() {
        guard let contentView = panel.contentView else { return }

        if let textInputView = firstTextInput(in: contentView) {
            panel.makeFirstResponder(textInputView)
        }
    }

    private func firstTextInput(in view: NSView) -> NSView? {
        if view is NSTextField {
            return view
        }

        for subview in view.subviews {
            if let match = firstTextInput(in: subview) {
                return match
            }
        }

        return nil
    }
}
