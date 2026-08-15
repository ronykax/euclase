import SwiftUI

struct ListView: View {
    let items: [Item]
    let selectedIndex: Int
    var onSelect: (Int) -> Void
    var onRun: (Int) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        row(item, selected: index == selectedIndex)
                            .id(item.id)
                            .onTapGesture(count: 2) { onRun(index) }
                            .onTapGesture { onSelect(index) }
                    }
                }
                .padding(.horizontal, 8)
            }
            .contentMargins(.bottom, 8, for: .scrollContent)
            .onChange(of: selectedIndex) {
                guard items.indices.contains(selectedIndex) else { return }
                proxy.scrollTo(items[selectedIndex].id)
            }
        }
        .frame(maxHeight: .infinity)
        .focusable(false)
    }

    func row(_ item: Item, selected: Bool) -> some View {
        HStack(spacing: 12) {
            Image(nsImage: item.icon)
                .resizable()
                // 128pt app icons have 12.5pt inset; scale that to 40pt
                .padding(item.kind == .command ? 12.5 * 40 / 128 : 0)
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(8)
        .background(selected ? .primary.opacity(0.1) : Color.clear, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
