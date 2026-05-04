import SwiftUI

struct ListView: View {
    let items: [String]
    @State private var query = ""
    
    var body: some View {
        TextInputView(
            query: $query,
            placeholder: "Browse the list...",
            onEscape: {
                ViewController.shared.goBack()
            }
        )
        .onAppear(perform: {
            print(items)
        })
    }
}
