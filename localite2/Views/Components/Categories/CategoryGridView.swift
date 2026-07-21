import SwiftUI

struct CategoryGridView: View {
    let categories: [CategoryItem]
    var onSelect: (CategoryItem) -> Void = { _ in }

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(categories) { item in
                CategoryTileButton(item: item, onSelect: onSelect)
            }
        }
    }
}

private struct CategoryTileButton: View {
    let item: CategoryItem
    let onSelect: (CategoryItem) -> Void
    @State private var isPressed = false

    var body: some View {
        Button {
            onSelect(item)
        } label: {
            CategoryTileView(item: item, isPressed: isPressed)
        }
        .buttonStyle(CategoryPressStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    CategoryGridView(categories: CategoryItem.sample).padding()
}
