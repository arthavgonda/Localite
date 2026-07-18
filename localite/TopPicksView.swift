import SwiftUI

struct TopPicksView: View {
    let station: Station
    @State private var selectedItem: LocalItem?
    
    // Define the items to make them easy to pass around
    let items = [
        LocalItem(title: "Fresh\nMangoes", subtitle: "Local Produce", imageName: "indian_fruits"),
        LocalItem(title: "Hot\nJalebis", subtitle: "Authentic Sweets", imageName: "indian_sweets"),
        LocalItem(title: "Handcrafted\nPottery", subtitle: "Traditional Crafts", imageName: "indian_handicrafts")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Top picks near")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(station.name)
                            .font(.title) // slightly larger font
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal)
                    .padding(.top, 24) // Normal padding is fine now that it scrolls from the top
                    
                    // Scrollable Cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(items) { item in
                                TopPickCardView(
                                    imageName: item.imageName,
                                    subtitle: item.subtitle,
                                    title: item.title,
                                    action: {
                                        selectedItem = item
                                    }
                                )
                            }
                            
                            // New Explore Card
                            NavigationLink(destination: Color.white.ignoresSafeArea().navigationTitle("Explore").navigationBarTitleDisplayMode(.inline)) {
                                ExploreMoreCardView()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20) 
                    }
                }
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(item: $selectedItem) { item in
            ItemDetailView(item: item)
        }
    }
}

struct TopPickCardView: View {
    let imageName: String
    let subtitle: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 330, height: 320)
                .clipped()
            
            // Stronger Gradient Overlay for text readability
            LinearGradient(
                gradient: Gradient(colors: [
                    .clear,
                    .black.opacity(0.4),
                    .black.opacity(0.9),
                    .black
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Text and Button Content
            VStack(alignment: .leading, spacing: 8) {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                
                Text(title)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .lineSpacing(2)
                
                Spacer().frame(height: 16)
                
                // Order Now Button
                Button(action: action) {
                    Text("KNOW MORE")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
            }
            .padding(24)
        }
        .frame(width: 330, height: 320) // Ensure ZStack matches image size
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}

struct ExploreMoreCardView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.gray.opacity(0.1))
            
            VStack(spacing: 12) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.blue)
                Text("Explore\nMore")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 180, height: 320)
    }
}
