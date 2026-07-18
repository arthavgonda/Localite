//
//  Roottabview.swift
//  localite
//
//  Created by ANOOP on 18/07/26.
//

import SwiftUI

struct RemoteImage: View {
    let seed: String
    var width: Int = 600
    var height: Int = 400

    private var url: URL? {
        URL(string: "https://picsum.photos/seed/\(seed)/\(width)/\(height)")
    }

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                ZStack {
                    Color.primary.opacity(0.06)
                    Image(systemName: "photo")
                        .foregroundStyle(.tertiary)
                }
            default:
                ZStack {
                    Color.primary.opacity(0.06)
                    ProgressView()
                }
            }
        }
    }
}

struct RootTabView: View {
    @StateObject private var nav = AppNavigation()

    var body: some View {
        ZStack {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }

                PlaceholderTabView(title: "Stores", icon: "storefront.fill")
                    .tabItem {
                        Label("Stores", systemImage: "storefront.fill")
                    }

                PlaceholderTabView(title: "Search", icon: "magnifyingglass")
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }

                PlaceholderTabView(title: "Orders", icon: "bag.fill")
                    .tabItem {
                        Label("Orders", systemImage: "bag.fill")
                    }

                PlaceholderTabView(title: "Account", icon: "person.crop.circle.fill")
                    .tabItem {
                        Label("Account", systemImage: "person.crop.circle.fill")
                    }
            }
            .tint(.primary)
            .environmentObject(nav)

            if let seller = nav.selectedSeller {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { closeDetail() }
                    .transition(.opacity)

                SellerDetailView(seller: seller, onClose: closeDetail)
                    .ignoresSafeArea()
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.97)),
                        removal: .opacity
                    ))
                    .zIndex(1)
            }
        }
    }

    private func closeDetail() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.88)) {
            nav.selectedSeller = nil
        }
    }
}

private struct PlaceholderTabView: View {
    let title: String
    let icon: String

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                Text("\(title) coming soon")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    RootTabView()
}
