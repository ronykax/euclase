import AppKit
import SwiftUI

struct LauncherView: View {
    var model: Model

    var body: some View {
        VStack(spacing: 0) {
            SearchBar(model: model)
            ListView(
                items: model.items,
                selectedIndex: model.selectedIndex,
                onSelect: { model.setSelected($0) },
                onRun: {
                    model.setSelected($0)
                    if NSEvent.modifierFlags.contains(.command) {
                        model.revealSelected()
                    } else {
                        model.runSelected()
                    }
                }
            )
        }
        .frame(width: 600, height: 400)
        .background(CustomBlur(material: .menu))
        // cmd+k menu — grows in at the corner, clipped to the launcher
        .overlay(alignment: .bottomTrailing) {
            ActionMenu(model: model)
                .padding(8)
                .scaleEffect(model.actionMenuOpen ? 1 : 0.05, anchor: .bottomTrailing)
                .opacity(model.actionMenuOpen ? 1 : 0)
                .blur(radius: model.actionMenuOpen ? 0 : 8)
                .allowsHitTesting(model.actionMenuOpen)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onExitCommand {
            if model.actionMenuOpen {
                withAnimation(.easeOut(duration: 0.15)) {
                    model.closeActionMenu()
                }
            } else {
                model.hide()
            }
        }
    }
}

struct CustomBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .hudWindow

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
    }
}
