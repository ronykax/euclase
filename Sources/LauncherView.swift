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
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onExitCommand { model.hide() }
    }
}
