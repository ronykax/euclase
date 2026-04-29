import SwiftUI

struct ContentView: View {
    @State private var inputText = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .scaledToFit()
                    .frame(width: 20, height: 16, alignment: .center)
                TextField("Search for apps and commands...", text: $inputText)
                    .textFieldStyle(.plain)
                    .font(.title3)
            }
            .padding()
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    RowItemView(selected: true, title: "Buape", description: "~/Documents/Assets/buape")
                    RowItemView(selected: false, title: "Buape", description: "~/Documents/Assets/buape")
                    RowItemView(selected: false, title: "Buape", description: "~/Documents/Assets/buape")
                    RowItemView(selected: false, title: "Buape", description: "~/Documents/Assets/buape")
                    RowItemView(selected: false, title: "Buape", description: "~/Documents/Assets/buape")
                    RowItemView(selected: false, title: "Buape", description: "~/Documents/Assets/buape")
                    RowItemView(selected: false, title: "Buape", description: "~/Documents/Assets/buape")
                    RowItemView(selected: false, title: "Buape", description: "~/Documents/Assets/buape")
                    RowItemView(selected: false, title: "Buape", description: "~/Documents/Assets/buape")
                    RowItemView(selected: false, title: "Buape", description: "~/Documents/Assets/buape")
                    RowItemView(selected: false, title: "Buape", description: "~/Documents/Assets/buape")
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct RowItemView: View {
    let selected: Bool
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
//            Image(systemName: "circle")
//                .font(.title)
//                .foregroundStyle(.clear)
//                .frame(width: 36, height: 36)
//                .background(.red, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            Image(systemName: "folder.fill")
                .font(.largeTitle)
                .frame(width: 36, height: 36)
                .foregroundStyle(.red)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.medium)
                    .font(.title3)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary.opacity(0.75))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.all, 8)
        .background(selected ? .secondary.opacity(0.25) : Color.clear, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
