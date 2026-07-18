//
//  HomeFeedView.swift
//  localite
//
//  Created by ANOOP on 18/07/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var nav: AppNavigation
    @State private var selectedCategory: LocalCategory = .all
    @Namespace private var chipNamespace

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    locationRow
                    searchBar
                    categoryChips

                    if selectedCategory == .all || selectedCategory == .fruits {
                        PopularSectionView(
                            title: "Popular Fruits",
                            highlights: LocalStore.highlights(for: .fruits),
                            onSelect: openSeller
                        )
                    }

                    if selectedCategory == .all || selectedCategory == .handicrafts {
                        PopularSectionView(
                            title: "Popular Handicrafts",
                            highlights: LocalStore.highlights(for: .handicrafts),
                            onSelect: openSeller
                        )
                    }

                    PromoBannerCarousel()
                }
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
    }

    private func openSeller(_ seller: Seller) {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.85)) {
            nav.selectedSeller = seller
        }
    }

    private var locationRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "mappin.circle.fill")
                .foregroundStyle(.orange)
            Text("Connaught Place, New Delhi")
                .font(.subheadline.weight(.semibold))
            Image(systemName: "chevron.down")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            Text("Fruits, handicrafts, artisans...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Button {
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(.secondary)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.leading, 16)
        .padding(.trailing, 4)
        .padding(.vertical, 4)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 20)
    }

    private var categoryChips: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(LocalCategory.allCases) { category in
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            selectedCategory = category
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.caption)
                            Text(category.rawValue)
                                .font(.subheadline.weight(.semibold))
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 40)
                        .foregroundStyle(selectedCategory == category ? Color.white : Color.primary)
                        .background {
                            if selectedCategory == category {
                                Capsule()
                                    .fill(Color.primary)
                                    .matchedGeometryEffect(id: "chipSelection", in: chipNamespace)
                            } else {
                                Capsule()
                                    .fill(Color(.secondarySystemGroupedBackground))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
    }
}

private struct PopularSectionView: View {
    let title: String
    let highlights: [PopularHighlight]
    let onSelect: (Seller) -> Void

    var body: some View {
        if !highlights.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.title3.weight(.bold))
                    Spacer()
                    Button {
                    } label: {
                        HStack(spacing: 4) {
                            Text("All")
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 20)

                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(highlights) { highlight in
                            PopularCard(highlight: highlight)
                                .onTapGesture { onSelect(highlight.seller) }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

private struct PopularCard: View {
    let highlight: PopularHighlight
    @State private var isFavorite = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                RemoteImage(seed: highlight.product.imageSeed, width: 400, height: 300)
                    .frame(width: 168, height: 128)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                        isFavorite.toggle()
                    }
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.caption)
                        .foregroundStyle(isFavorite ? .red : .primary)
                        .frame(width: 28, height: 28)
                        .background(.white, in: Circle())
                        .frame(width: 44, height: 44)
                }

                VStack {
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", highlight.seller.rating))
                            .font(.caption.weight(.bold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.white, in: Capsule())
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Text(highlight.seller.category.rawValue.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(.orange)

            Text(highlight.product.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)

            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 10))
                    Text(highlight.seller.distance)
                }
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 10))
                    Text(highlight.seller.etaText)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(width: 168)
    }
}

private struct PromoBannerCarousel: View {
    private let banners: [(title: String, subtitle: String, seed: String, color: Color)] = [
        ("Monsoon Mango Sale", "Up to 25% off, this week only", "mango-banner-01", Color(red: 1.0, green: 0.93, blue: 0.8)),
        ("Handicraft Fest", "Curated pieces from 12 artisans", "craft-banner-01", Color(red: 0.88, green: 0.92, blue: 1.0))
    ]

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(banners, id: \.title) { banner in
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(banner.title)
                                .font(.headline)
                            Text(banner.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.leading, 16)
                        .frame(width: 170, alignment: .leading)

                        RemoteImage(seed: banner.seed, width: 300, height: 300)
                            .frame(width: 110, height: 110)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .padding(.trailing, 12)
                    }
                    .frame(height: 130)
                    .background(banner.color, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppNavigation())
}
