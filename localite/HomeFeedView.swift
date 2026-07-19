import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject private var nav: AppNavigation
    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var locationStore: LocationStore
    @State private var showCart = false
    @State private var showLocationPicker = false
    @State private var selectedCategory: LocalCategory = .fruits
    @State private var seeAllTitle: String? = nil
    @State private var seeAllItems: [Product] = []
    @State private var pushSeeAll = false

    private var crossSellCategory: LocalCategory {
        selectedCategory == .handicrafts ? .fruits : .handicrafts
    }

    private var crossSellTitle: String {
        crossSellCategory == .handicrafts ? "Regional handicrafts" : "Fresh produce"
    }

    private var passportHighlight: SeasonalHighlight? {
        LocalStore.seasonalHighlights.first(where: { $0.category == selectedCategory })
            ?? LocalStore.seasonalHighlights.first
    }

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    topBar

                    CategorySegmentedControl(selection: $selectedCategory, categories: LocalCategory.browsable)

                    if let highlight = passportHighlight {
                        PassportHeroCard(highlight: highlight) {
                            openProduct(highlight.product, sourceID: highlight.product.id.uuidString)
                        }
                    }

                    ProductStripSection(
                        title: "Fresh this week",
                        items: LocalStore.allItems(for: selectedCategory),
                        onSelect: openProduct,
                        onAdd: addToCart,
                        onSeeAll: {
                            seeAllTitle = "Fresh this week"
                            seeAllItems = LocalStore.allItems(for: selectedCategory)
                            pushSeeAll = true
                        }
                    )

                    ProductStripSection(
                        title: crossSellTitle,
                        items: LocalStore.allItems(for: crossSellCategory),
                        onSelect: openProduct,
                        onAdd: addToCart,
                        onSeeAll: {
                            seeAllTitle = crossSellTitle
                            seeAllItems = LocalStore.allItems(for: crossSellCategory)
                            pushSeeAll = true
                        }
                    )
                }
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
        .sheet(isPresented: $showCart) {
            CartView(onClose: { showCart = false })
        }
        .sheet(isPresented: $showLocationPicker) {
            LocationPickerSheet()
                .environmentObject(locationStore)
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
        }
        .navigationDestination(isPresented: $pushSeeAll) {
            AllProductsView(
                title: seeAllTitle ?? "",
                items: seeAllItems,
                onSelect: openProduct,
                onAdd: addToCart
            )
            .environmentObject(cart)
            .environmentObject(nav)
            .environmentObject(locationStore)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func openProduct(_ product: Product, sourceID: String) {
        nav.selectedSourceID = sourceID
        withAnimation(.spring(response: 0.55, dampingFraction: 0.85)) {
            nav.selectedProduct = product
        }
    }

    private func addToCart(_ product: Product) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            cart.add(product)
        }
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            HStack(alignment: .center, spacing: 6) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Home")
                        .font(.largeTitle.weight(.bold))

                    Button {
                        showLocationPicker = true
                    } label: {
                        HStack(spacing: 6) {
                            if locationStore.selected.isLive {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Color(red: 0.18, green: 0.55, blue: 0.24))
                            } else {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(LocaliteTheme.accent)
                            }
                            Text(locationStore.selected.shortName)
                                .font(.headline.weight(.bold))
                                .foregroundStyle(LocaliteTheme.ink)
                            Image(systemName: "chevron.down")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(LocaliteTheme.inkMuted)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()

            Button {
                showCart = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "cart.fill")
                        .font(.subheadline)
                        .foregroundStyle(LocaliteTheme.ink)
                        .frame(width: 40, height: 40)
                        .background(Color.white, in: Circle())
                        .overlay(
                            Circle().strokeBorder(Color.gray.opacity(0.2), lineWidth: 0.5)
                        )

                    if cart.uniqueItemCount > 0 {
                        Text("\(cart.uniqueItemCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 16, height: 16)
                            .background(LocaliteTheme.accent, in: Circle())
                            .offset(x: 2, y: -2)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

private struct CategorySegmentedControl: View {
    @Binding var selection: LocalCategory
    let categories: [LocalCategory]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(categories) { category in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        selection = category
                    }
                } label: {
                    Text(category.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(selection == category ? LocaliteTheme.ink : LocaliteTheme.inkSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(selection == category ? Color.white : Color.clear)
                                .shadow(color: .black.opacity(selection == category ? 0.12 : 0), radius: 3, y: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(LocaliteTheme.surfaceMuted, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, 20)
    }
}

private struct PassportHeroCard: View {
    let highlight: SeasonalHighlight
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topLeading) {
                LinearGradient(
                    colors: [LocaliteTheme.Passport.gradientTop, LocaliteTheme.Passport.gradientBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Text("CERT.\nLOCAL")
                    .font(.system(size: 8, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(LocaliteTheme.Passport.subtitle)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(.white.opacity(0.14)))
                    .overlay(Circle().strokeBorder(.white.opacity(0.35), lineWidth: 1))
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                VStack(alignment: .leading, spacing: 6) {
                    Text(highlight.badge.uppercased())
                        .font(.caption.weight(.bold))
                        .tracking(0.8)
                        .foregroundStyle(LocaliteTheme.Passport.subtitle)

                    Text(highlight.title)
                        .font(.title2.weight(.heavy))
                        .foregroundStyle(.white)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: 210, alignment: .topLeading)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(highlight.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(LocaliteTheme.Passport.subtitle)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(minHeight: 40, alignment: .topLeading)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)

                    HStack(spacing: 22) {
                        statColumn(value: String(format: "%.1f ★", highlight.rating), label: "\(highlight.ratingCount) orders")
                        statColumn(value: highlight.windowValue, label: highlight.windowLabel)
                        statColumn(value: highlight.priceValue, label: highlight.priceLabel)
                    }
                }
                .padding(22)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 200)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
    }

    private func statColumn(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(LocaliteTheme.Passport.statLabel)
        }
    }
}

private struct ProductStripSection: View {
    let title: String
    let items: [Product]
    let onSelect: (Product, String) -> Void
    let onAdd: (Product) -> Void
    let onSeeAll: () -> Void

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(LocaliteTheme.ink)
                    Spacer()
                    Button(action: onSeeAll) {
                        Text("See all")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(LocaliteTheme.accent)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)

                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 14) {
                        ForEach(items) { product in
                            ProductStripCard(product: product) {
                                onAdd(product)
                            }
                            .onTapGesture { onSelect(product, product.id.uuidString) }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

private struct ProductStripCard: View {
    let product: Product
    let onAdd: () -> Void
    @Environment(\.heroNamespace) private var heroNamespace
    @State private var isBouncing = false
    @State private var addTrigger = 0

    private func triggerAdd() {
        addTrigger += 1
        withAnimation(.easeOut(duration: 0.1)) {
            isBouncing = true
        }
        onAdd()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                isBouncing = false
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                RemoteImage(seed: product.imageSeed, width: 400, height: 400)
                    .matchedGeometryEffectIfAvailable(id: product.id.uuidString, in: heroNamespace)
                    .frame(width: 160, height: 120)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 20,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 20,
                            style: .continuous
                        )
                    )
                    .clipped()

                if let discount = product.discountPercent {
                    Text("-\(discount)%")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(LocaliteTheme.accent, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .padding(10)
                }

                Image(systemName: "plus")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(LocaliteTheme.ink, in: Circle())
                    .scaleEffect(isBouncing ? 0.85 : 1.0)
                    .contentShape(Circle())
                    .highPriorityGesture(TapGesture().onEnded(triggerAdd))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(10)
                    .sensoryFeedback(.impact(weight: .light), trigger: addTrigger)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(LocaliteTheme.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minHeight: 36, alignment: .topLeading)

                HStack(spacing: 6) {
                    Text(product.price)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(LocaliteTheme.ink)
                    if let original = product.originalPrice {
                        Text(original)
                            .font(.caption2)
                            .strikethrough()
                            .foregroundStyle(Color.gray)
                    }
                }
            }
            .padding(.top, 10)
        }
        .frame(width: 160, alignment: .leading)
        .padding(10)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppNavigation())
        .environmentObject(CartStore())
}
