import SwiftUI

struct ListView: View {
    let items: [Item]
    let selectedIndex: Int
    var onSelect: (Int) -> Void
    var onRun: (Int) -> Void

    var body: some View {
        // scrollview + vstack so we don't auto-scroll to the selection
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    row(item, selected: index == selectedIndex)
                        .onTapGesture(count: 2) { onRun(index) }
                        .onTapGesture { onSelect(index) }
                }
            }
        }
        .frame(maxHeight: .infinity)
        .focusable(false)
    }

    func row(_ item: Item, selected: Bool) -> some View {
        HStack(spacing: 8) {
            Image(nsImage: item.icon)
                .resizable()
                .frame(width: 24, height: 24)
                // .border(.red)
            Text(item.title)
                .font(.body)
                .foregroundStyle(.primary)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(selected ? Color.accentColor.opacity(0.3) : Color.clear)
        .contentShape(Rectangle())
    }
}
