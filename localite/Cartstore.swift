import SwiftUI
import Combine

struct CartLine: Identifiable {
    let id: UUID
    let product: Product
    var quantity: Int

    init(product: Product, quantity: Int = 1) {
        self.id = product.id
        self.product = product
        self.quantity = quantity
    }
}

struct LocalCartLine: Identifiable {
    let id: UUID
    let item: LocalItem
    var quantity: Int

    init(item: LocalItem, quantity: Int = 1) {
        self.id = item.id
        self.item = item
        self.quantity = quantity
    }
}

final class CartStore: ObservableObject {
    @Published private(set) var lines: [CartLine] = []
    @Published private(set) var localLines: [LocalCartLine] = []

    var totalCount: Int {
        lines.reduce(0) { $0 + $1.quantity } + localLines.reduce(0) { $0 + $1.quantity }
    }

    var uniqueItemCount: Int {
        lines.count + localLines.count
    }

    func quantity(for product: Product) -> Int {
        lines.first(where: { $0.product.id == product.id })?.quantity ?? 0
    }

    func localQuantity(for item: LocalItem) -> Int {
        localLines.first(where: { $0.item.id == item.id })?.quantity ?? 0
    }

    func add(_ product: Product, quantity: Int = 1) {
        if let index = lines.firstIndex(where: { $0.product.id == product.id }) {
            lines[index].quantity += quantity
        } else {
            lines.append(CartLine(product: product, quantity: quantity))
        }
    }

    func addLocal(_ item: LocalItem, quantity: Int = 1) {
        if let index = localLines.firstIndex(where: { $0.item.id == item.id }) {
            localLines[index].quantity += quantity
        } else {
            localLines.append(LocalCartLine(item: item, quantity: quantity))
        }
    }

    func decrement(_ product: Product) {
        guard let index = lines.firstIndex(where: { $0.product.id == product.id }) else { return }
        if lines[index].quantity > 1 {
            lines[index].quantity -= 1
        } else {
            lines.remove(at: index)
        }
    }

    func decrementLocal(_ item: LocalItem) {
        guard let index = localLines.firstIndex(where: { $0.item.id == item.id }) else { return }
        if localLines[index].quantity > 1 {
            localLines[index].quantity -= 1
        } else {
            localLines.remove(at: index)
        }
    }

    func remove(_ line: CartLine) {
        lines.removeAll { $0.id == line.id }
    }

    func removeLocal(_ line: LocalCartLine) {
        localLines.removeAll { $0.id == line.id }
    }

    func clear() {
        lines.removeAll()
        localLines.removeAll()
    }
}

struct CartView: View {
    @EnvironmentObject private var cart: CartStore
    let onClose: () -> Void

    @State private var showOrderPlacedIsland = false
    @State private var checkoutTrigger = 0
    @State private var dismissWorkItem: DispatchWorkItem?

    private var subtotal: Int {
        let productTotal = cart.lines.reduce(0) { $0 + priceValue($1.product.price) * $1.quantity }
        let localTotal = cart.localLines.reduce(0) { $0 + Int($1.item.price) * $1.quantity }
        return productTotal + localTotal
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            Group {
                if cart.lines.isEmpty && cart.localLines.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(cart.lines) { line in
                            CartLineRow(
                                line: line,
                                onIncrement: { cart.add(line.product) },
                                onDecrement: { cart.decrement(line.product) }
                            )
                            .listRowInsets(EdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20))
                            .listRowBackground(LocaliteTheme.background)
                            .listRowSeparatorTint(LocaliteTheme.hairline)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        cart.remove(line)
                                    }
                                } label: { Label("Remove", systemImage: "trash") }
                            }
                        }

                        ForEach(cart.localLines) { line in
                            LocalCartLineRow(
                                line: line,
                                onIncrement: { cart.addLocal(line.item) },
                                onDecrement: { cart.decrementLocal(line.item) }
                            )
                            .listRowInsets(EdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20))
                            .listRowBackground(LocaliteTheme.background)
                            .listRowSeparatorTint(LocaliteTheme.hairline)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        cart.removeLocal(line)
                                    }
                                } label: { Label("Remove", systemImage: "trash") }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .safeAreaInset(edge: .bottom) { summaryBar }
                }
            }
        }
        .background(LocaliteTheme.background)
        .sensoryFeedback(.impact(weight: .medium), trigger: checkoutTrigger)
        .overlay(alignment: .top) {
            if showOrderPlacedIsland {
                OrderPlacedIsland(subtotal: subtotal)
                    .padding(.top, 11)
                    .ignoresSafeArea(edges: .top)
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.4, anchor: .top).combined(with: .opacity),
                            removal: .scale(scale: 0.6, anchor: .top).combined(with: .opacity)
                        )
                    )
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.72), value: showOrderPlacedIsland)
    }

    private func placeOrder() {
        checkoutTrigger += 1
        dismissWorkItem?.cancel()
        showOrderPlacedIsland = true

        let workItem = DispatchWorkItem {
            showOrderPlacedIsland = false
            cart.clear()
            onClose()
        }
        dismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8, execute: workItem)
    }

    private var header: some View {
        HStack {
            headerPill(title: "Close", action: onClose)

            Spacer()

            Text("Your cart")
                .font(.headline.weight(.bold))
                .foregroundStyle(LocaliteTheme.ink)

            Spacer()

            if !cart.lines.isEmpty || !cart.localLines.isEmpty {
                headerPill(title: "Clear", tint: LocaliteTheme.accent) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        cart.clear()
                    }
                }
            } else {
                Color.clear.frame(width: 66, height: 1)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 14)
    }

    private func headerPill(title: String, tint: Color = LocaliteTheme.ink, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().strokeBorder(.white.opacity(0.5), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.1), radius: 8, y: 3)
        }
    }

    private var summaryBar: some View {
        VStack(spacing: 16) {
            Divider()
                .overlay(LocaliteTheme.hairline)

            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(cart.totalCount) item\(cart.totalCount == 1 ? "" : "s") · Subtotal")
                        .font(.caption)
                        .foregroundStyle(LocaliteTheme.inkSecondary)
                    Text("₹\(subtotal)")
                        .font(.title3.weight(.heavy))
                        .foregroundStyle(LocaliteTheme.ink)
                }

                Spacer()

                Button(action: placeOrder) {
                    Text("Checkout")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 26)
                        .padding(.vertical, 14)
                        .background(LocaliteTheme.ink, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 4)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bag")
                .font(.system(size: 40))
                .foregroundStyle(LocaliteTheme.inkMuted)
            Text("Your cart is empty")
                .font(.headline)
                .foregroundStyle(LocaliteTheme.ink)
            Text("Items you add will show up here.")
                .font(.subheadline)
                .foregroundStyle(LocaliteTheme.inkSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LocaliteTheme.background)
    }
}

private func priceValue(_ price: String) -> Int {
    Int(price.filter(\.isNumber)) ?? 0
}

private struct LocalCartLineRow: View {
    let line: LocalCartLine
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    @State private var stepTrigger = 0

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(LocaliteTheme.surfaceMuted)
                    .frame(width: 64, height: 64)
                Image(line.item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(line.item.title.replacingOccurrences(of: "\n", with: " "))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(LocaliteTheme.ink)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(LocaliteTheme.inkMuted)
                    Text(line.item.origin)
                        .font(.caption)
                        .foregroundStyle(LocaliteTheme.inkSecondary)
                }

                HStack {
                    stepper
                    Spacer()
                    Text("₹\(Int(line.item.price))")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(LocaliteTheme.ink)
                }
                .padding(.top, 4)
            }
        }
    }

    private var stepper: some View {
        HStack(spacing: 12) {
            Button(action: {
                stepTrigger += 1
                onDecrement()
            }) {
                Image(systemName: "minus")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(LocaliteTheme.inkSecondary)
                    .frame(width: 22, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Text("\(line.quantity)")
                .font(.caption.weight(.bold))
                .foregroundStyle(LocaliteTheme.ink)
                .frame(minWidth: 14)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: line.quantity)

            Button(action: {
                stepTrigger += 1
                onIncrement()
            }) {
                Image(systemName: "plus")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(LocaliteTheme.ink)
                    .frame(width: 22, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(LocaliteTheme.surfaceMuted, in: Capsule())
        .sensoryFeedback(.impact(weight: .light), trigger: stepTrigger)
    }
}

private struct CartLineRow: View {
    let line: CartLine
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    @State private var stepTrigger = 0

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            RemoteImage(seed: line.product.imageSeed, width: 200, height: 200)
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(line.product.name)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(LocaliteTheme.ink)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(LocaliteTheme.inkMuted)
                    Text(line.product.originVillage)
                        .font(.caption)
                        .foregroundStyle(LocaliteTheme.inkSecondary)
                }

                HStack {
                    stepper
                    Spacer()
                    Text(line.product.price)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(LocaliteTheme.ink)
                }
                .padding(.top, 4)
            }
        }
    }

    private var stepper: some View {
        HStack(spacing: 12) {
            Button(action: {
                stepTrigger += 1
                onDecrement()
            }) {
                Image(systemName: "minus")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(LocaliteTheme.inkSecondary)
                    .frame(width: 22, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Text("\(line.quantity)")
                .font(.caption.weight(.bold))
                .foregroundStyle(LocaliteTheme.ink)
                .frame(minWidth: 14)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: line.quantity)

            Button(action: {
                stepTrigger += 1
                onIncrement()
            }) {
                Image(systemName: "plus")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(LocaliteTheme.ink)
                    .frame(width: 22, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(LocaliteTheme.surfaceMuted, in: Capsule())
        .sensoryFeedback(.impact(weight: .light), trigger: stepTrigger)
    }
}

private struct OrderPlacedIsland: View {
    let subtotal: Int
    @State private var checkmarkTrigger = 0

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: checkmarkTrigger)

            VStack(alignment: .leading, spacing: 1) {
                Text("Order placed")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                Text("₹\(subtotal) · On its way")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.65))
            }
        }
        .padding(.leading, 14)
        .padding(.trailing, 18)
        .padding(.vertical, 12)
        .background(Capsule(style: .continuous).fill(Color.black))
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(.white.opacity(0.08), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.4), radius: 22, y: 10)
        .onAppear { checkmarkTrigger += 1 }
    }
}

struct CartAddedBanner: View {
    let title: String
    let detail: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.16))
                        .frame(width: 30, height: 30)
                    Image(systemName: "bag.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.45))
            }
            .padding(.leading, 14)
            .padding(.trailing, 16)
            .padding(.vertical, 12)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.black)
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(.white.opacity(0.08), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.35), radius: 24, y: 10)
        }
        .buttonStyle(.plain)
    }
}

struct CartAddedBannerOverlay: ViewModifier {
    @EnvironmentObject private var cart: CartStore
    let product: Product
    var ctaBarHeight: CGFloat = 0
    let onOpenCart: () -> Void

    @State private var justAdded = false
    @State private var settleWorkItem: DispatchWorkItem?

    private var quantityInCart: Int {
        cart.quantity(for: product)
    }

    private var title: String {
        justAdded ? "Added \(product.name)" : "In your basket"
    }

    private var detailText: String {
        let count = quantityInCart == 1 ? "1 in your basket" : "\(quantityInCart) in your basket"
        return "\(count) · Tap to view cart"
    }

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if quantityInCart > 0 {
                    CartAddedBanner(title: title, detail: detailText) {
                        onOpenCart()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, ctaBarHeight + 10)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        )
                    )
                }
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.82), value: quantityInCart)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: justAdded)
            .onChange(of: quantityInCart) { oldValue, newValue in
                guard newValue > oldValue else { return }
                settleWorkItem?.cancel()
                justAdded = true
                let workItem = DispatchWorkItem { justAdded = false }
                settleWorkItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6, execute: workItem)
            }
    }
}

extension View {
    func cartAddedBanner(for product: Product, ctaBarHeight: CGFloat = 0, onOpenCart: @escaping () -> Void) -> some View {
        modifier(CartAddedBannerOverlay(product: product, ctaBarHeight: ctaBarHeight, onOpenCart: onOpenCart))
    }
}
