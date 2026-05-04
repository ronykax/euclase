import SwiftUI
import AppKit

struct RootSearchView: View {
    @State private var query = ""
    @State private var extensions: [Extension] = []
    @State private var apps: [DiscoveredApp] = []
    @State private var selectedIndex = 0

    var body: some View {
        VStack(spacing: 0) {
            TextInputView(
                query: $query,
                placeholder: "Search for apps and commands...",
                onEscape: {
                    AppDelegate.shared?.hidePanel()
                },
                onUpArrow: selectPreviousItem,
                onDownArrow: selectNextItem,
                onReturn: runSelectedItem
            )

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(filteredSearchItems.enumerated()), id: \.element.id) { index, item in
                        searchItemRow(for: item, isSelected: index == selectedIndex)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedIndex = index
                            }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .scrollIndicators(.hidden)
        }
        .onAppear(perform: loadData)
        .onChange(of: query) {
            selectedIndex = 0
        }
    }

    private var allSearchItems: [SearchItem] {
        commandSearchItems() + appSearchItems()
    }

    private var filteredSearchItems: [SearchItem] {
        guard !query.isEmpty else {
            return allSearchItems
        }

        let normalizedQuery = query.lowercased()
        return allSearchItems.filter { item in
            item.title.lowercased().contains(normalizedQuery)
        }
    }

    private var selectedItem: SearchItem {
        filteredSearchItems[selectedIndex]
    }

    private func commandSearchItems() -> [SearchItem] {
        extensions.flatMap { discoveredExtension in
            discoveredExtension.commands.map { command in
                SearchItem(
                    id: "command:\(discoveredExtension.id):\(command.name)",
                    title: command.name,
                    kind: .command(
                        extensionID: discoveredExtension.id,
                        commandName: command.name,
                        commandDescription: command.description
                    )
                )
            }
        }
    }

    private func appSearchItems() -> [SearchItem] {
        apps.map { app in
            SearchItem(
                id: "app:\(app.path)",
                title: app.name,
                kind: .app(path: app.path)
            )
        }
    }

    private func loadData() {
        extensions = ExtensionDiscoveryService().discoverExtensions()
        apps = AppDiscoveryService().discoverApps()
    }

    private func run(item: SearchItem) {
        switch item.kind {
        case let .command(extensionID, commandName, _):
            runCommand(extensionID: extensionID, commandName: commandName)
        case let .app(path):
            openApp(path: path)
        }
    }

    private func selectPreviousItem() {
        guard !filteredSearchItems.isEmpty else {
            return
        }

        selectedIndex = max(selectedIndex - 1, 0)
    }

    private func selectNextItem() {
        guard !filteredSearchItems.isEmpty else {
            return
        }

        selectedIndex = min(selectedIndex + 1, filteredSearchItems.count - 1)
    }

    private func runSelectedItem() {
        guard !filteredSearchItems.isEmpty else {
            return
        }

        run(item: selectedItem)
    }

    @ViewBuilder
    private func searchItemRow(for item: SearchItem, isSelected: Bool) -> some View {
        HStack(spacing: 16) {
            searchItemIcon(for: item)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.title3)
                    .fontWeight(.medium)
                Text(searchItemSubtitle(for: item))
                    .font(.caption)
                    .fontWeight(.regular)
                    .foregroundStyle(.secondary.opacity(0.75))
            }
            Spacer(minLength: 0)
        }
        .padding(.all, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? Color.secondary.opacity(0.25) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private func searchItemIcon(for item: SearchItem) -> some View {
        switch item.kind {
        case .command:
            Image(systemName: "diamond.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
        case let .app(path):
            appIcon(path: path)
        }
    }

    private func searchItemSubtitle(for item: SearchItem) -> String {
        switch item.kind {
        case let .command(_, _, commandDescription):
            return commandDescription
        case let .app(path):
            return path
        }
    }

    private func appIcon(path: String) -> some View {
        let icon = NSWorkspace.shared.icon(forFile: path)
        let trimmedIcon = icon.trimmedToOpaqueBounds() ?? icon

        return Image(nsImage: trimmedIcon)
            .resizable()
            .interpolation(.high)
            .scaledToFill()
            .frame(width: 36, height: 36)
            .clipped()
    }

    private func runCommand(extensionID: String, commandName: String) {
        let commandPath = commandFilePath(extensionID: extensionID, commandName: commandName)

        CommandRunner.run(file: commandPath) { message in
            handleMessage(message)
        }
    }

    private func openApp(path: String) {
        AppDelegate.shared?.hidePanel()
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
    }

    private func commandFilePath(extensionID: String, commandName: String) -> String {
        "/Users/rony/.config/euclase/extensions/\(extensionID)/commands/\(commandName).ts"
    }

    private func handleMessage(_ message: String) {
        // Commands can emit multiple JSON messages in a single stdout payload.
        // Process each non-empty line independently.
        let lines = message.split(whereSeparator: \.isNewline).map(String.init)
        if lines.count > 1 {
            for line in lines {
                handleMessage(line)
            }
            return
        }

        guard
            let data = message.data(using: .utf8),
            let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let method = payload["method"] as? String
        else {
            print(message)
            return
        }

        switch method {
        case "print":
            guard let params = payload["params"] else {
                print(message)
                return
            }
            print(params)
        case "show-list":
            guard let params = payload["params"] else {
                return
            }
            guard let items = parseListItems(from: params) else {
                print(message)
                return
            }
            ViewController.shared.showList(items: items)
        case "hide":
            AppDelegate.shared?.hidePanel()
        default:
            print(message)
        }
    }

    private func parseListItems(from params: Any) -> [String]? {
        if let items = params as? [String] {
            return items
        }

        if let item = params as? String {
            return [item]
        }

        if
            let payload = params as? [String: Any],
            let items = payload["items"] as? [String]
        {
            return items
        }

        return nil
    }
}

private struct SearchItem: Identifiable {
    let id: String
    let title: String
    let kind: SearchItemKind
}

private enum SearchItemKind {
    case command(extensionID: String, commandName: String, commandDescription: String)
    case app(path: String)
}

private extension NSImage {
    func trimmedToOpaqueBounds(alphaThreshold: UInt8 = 1) -> NSImage? {
        guard
            let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil),
            let dataProvider = cgImage.dataProvider,
            let rawData = dataProvider.data,
            let bytes = CFDataGetBytePtr(rawData)
        else {
            return nil
        }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = cgImage.bytesPerRow
        let bytesPerPixel = max(cgImage.bitsPerPixel / 8, 1)

        guard bytesPerPixel >= 4 else {
            return nil
        }

        let alphaOffset: Int
        switch cgImage.alphaInfo {
        case .premultipliedFirst, .first, .noneSkipFirst:
            alphaOffset = 0
        case .premultipliedLast, .last, .noneSkipLast:
            alphaOffset = 3
        default:
            return nil
        }

        var minX = width
        var minY = height
        var maxX = -1
        var maxY = -1

        for y in 0..<height {
            for x in 0..<width {
                let index = (y * bytesPerRow) + (x * bytesPerPixel) + alphaOffset
                let alpha = bytes[index]
                if alpha >= alphaThreshold {
                    minX = min(minX, x)
                    minY = min(minY, y)
                    maxX = max(maxX, x)
                    maxY = max(maxY, y)
                }
            }
        }

        guard maxX >= minX, maxY >= minY else {
            return nil
        }

        let rect = CGRect(
            x: minX,
            y: minY,
            width: (maxX - minX) + 1,
            height: (maxY - minY) + 1
        )

        guard let cropped = cgImage.cropping(to: rect) else {
            return nil
        }

        return NSImage(
            cgImage: cropped,
            size: NSSize(width: rect.width, height: rect.height)
        )
    }
}
