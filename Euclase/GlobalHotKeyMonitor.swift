import Carbon
import Foundation

final class GlobalHotKeyMonitor {
    // Carbon requires an ID when registering a hotkey even if we don't
    // inspect the incoming EventHotKeyID in the handler.
    private static let registrationHotKeyID = EventHotKeyID(
        signature: OSType(0x4555434C), // "EUCL"
        id: 1
    )

    private var eventHandlerRef: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?
    private var handler: (() -> Void)?

    func start(keyCode: UInt32, modifiers: UInt32, handler: @escaping () -> Void) -> Bool {
        stop()
        self.handler = handler

        var eventSpec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let eventHandlerStatus = InstallEventHandler(
            GetEventDispatcherTarget(),
            { _, event, userData in
                guard
                    let userData,
                    let event
                else { return noErr }

                let monitor = Unmanaged<GlobalHotKeyMonitor>
                    .fromOpaque(userData)
                    .takeUnretainedValue()
                monitor.handleHotKeyEvent(event)
                return noErr
            },
            1,
            &eventSpec,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandlerRef
        )

        guard eventHandlerStatus == noErr else {
            #if DEBUG
            print("Global hotkey handler install failed: \(eventHandlerStatus)")
            #endif
            stop()
            return false
        }

        let registerStatus = RegisterEventHotKey(
            keyCode,
            modifiers,
            Self.registrationHotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )

        guard registerStatus == noErr else {
            #if DEBUG
            print("Global hotkey registration failed: \(registerStatus)")
            #endif
            stop()
            return false
        }

        #if DEBUG
        print("Global hotkey registered")
        #endif
        return true
    }

    func stop() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }

        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }

        handler = nil
    }

    deinit {
        stop()
    }

    private func handleHotKeyEvent(_: EventRef) {
        if Thread.isMainThread {
            handler?()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.handler?()
            }
        }
    }
}
