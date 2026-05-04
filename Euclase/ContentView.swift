import SwiftUI

struct ContentView: View {
    @StateObject var vc = ViewController.shared

    var body: some View {
        Group {
            switch vc.current {
            case .root:
                RootSearchView()
            case .list(let items):
                ListView(items: items)
            case .grid(let items):
                GridView(items: items)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            CustomBlur(material: .hudWindow)
                .overlay(.black.opacity(0.25))
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
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
