import SwiftUI
import Combine

struct HomeView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel = HomeViewModel()
    @State private var tabBarHeight: CGFloat = 0

    var body: some View {
        let theme = theme(colorScheme)

        ZStack(alignment: .bottom) {
            theme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ScrollOffsetReader(coordinateSpace: "homeScroll")
                                .frame(height: 0)
                    TopNavBar(onCartTap: {})

                    GreetingHeaderView(
                        greeting: viewModel.greeting,
                        locationLabel: viewModel.locationLabel,
                        mode: viewModel.mode,
                        onEndJourney: viewModel.endJourney
                    )

                    VStack(spacing: 12) {
                        GeometryReader { geo in
                            HStack(alignment: .top, spacing: 12) {
                                HeroCardView(product: viewModel.heroProduct)
                                    .frame(width: geo.size.width * 0.608)

                                JourneyDialView(
                                    mode: viewModel.mode,
                                    journeyInfo: viewModel.journeyInfo,
                                    displayedMinutes: viewModel.displayedDialMinutes,
                                    onAddPNR: viewModel.presentPNREntry
                                )
                            }
                        }
                        .frame(height: 230)

                        RouteMapView(
                            mode: viewModel.mode,
                            journeyInfo: viewModel.journeyInfo,
                            curatedRegionsCount: viewModel.curatedRegionsCount
                        )

                        SectionTitle(text: "Browse by category")
                        CategoryGridView(categories: viewModel.categories)

                        SectionTitle(text: "Local Picks · Delhi")
                        LocalPicksStackView(products: viewModel.localPicks)

                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, tabBarHeight + 50)
                    
                }
            }
            .coordinateSpace(name: "homeScroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { viewModel.scrollOffset = $0 }

            CustomTabBar(
                selected: $viewModel.selectedTab,
                mode: viewModel.mode,
                onCenterTap: {
                    if viewModel.mode == .journey {
                        viewModel.endJourney()
                    } else {
                        viewModel.presentPNREntry()
                    }
                }
            )
            .padding(.horizontal, 18)
            .padding(.bottom, 10)
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(key: TabBarHeightPreferenceKey.self, value: proxy.size.height)
                }
            )
        }
        .onPreferenceChange(TabBarHeightPreferenceKey.self) { measuredHeight in
            tabBarHeight = measuredHeight + 20
        }
        .sheet(isPresented: $viewModel.isShowingPNREntry) {
            PNRTrackScreen()
        }
    }
}

#Preview("Light") {
    HomeView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    HomeView()
        .preferredColorScheme(.dark)
}
