import SwiftUI

struct ContentView: View {
    @StateObject var vc = ViewController()

    var body: some View {
        switch vc.current {
        case .root:
            RootSearchView()
        case .list(let items):
            ListView(items: items)
        case .grid(let items):
            GridView(items: items)
        }
    }
}
