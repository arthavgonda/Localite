import SwiftUI

struct LocalItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
    var description: String = ""
}

struct ItemDetailView: View {
    let item: LocalItem
    @State private var isGenerating = true
    @State private var generatedText = ""
    @Environment(\.dismiss) var dismiss
    
    // Simulated AI response based on item
    private var simulatedAIResponse: String {
        switch item.title {
        case "Fresh\nMangoes":
            return "Mangoes are deeply embedded in Indian culture and history, often referred to as the 'King of Fruits'. Locally sourced mangoes offer a vibrant, sweet flavor with a rich, aromatic profile. They are commonly enjoyed fresh, blended into refreshing lassis, or used in tangy pickles and chutneys. The local climate provides the perfect conditions for growing some of the finest varieties, making them a seasonal favorite among residents and a must-try for visitors seeking authentic local produce."
        case "Hot\nJalebis":
            return "Jalebi is a beloved traditional sweet across India, famous for its vibrant orange color and crystalline, syrupy crunch. Made by deep-frying a wheat flour batter in circular shapes and immediately soaking it in sugar syrup scented with saffron and cardamom, it is best enjoyed piping hot. Often paired with creamy rabdi or crisp samosas for breakfast, finding a local sweet shop that perfects the delicate balance of a crispy exterior and a juicy interior is a true delight."
        case "Handcrafted\nPottery":
            return "Indian handcrafted pottery is a testament to centuries-old artistic traditions passed down through generations. Local artisans use locally sourced clay, shaping it meticulously on traditional wheels before firing it in earthen kilns. These pieces range from everyday functional items like 'kulhads' (tea cups) and water pitchers to intricately painted decorative artifacts. Purchasing these crafts directly supports local artisan communities and helps preserve this incredible, tactile art form."
        default:
            return "This local gem is a wonderful discovery! Known for its unique characteristics and deep roots in the community, it represents the heart of local culture. Visitors and locals alike appreciate the craftsmanship, flavor, and history that makes this item truly special."
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Hero Image
                ZStack(alignment: .topTrailing) {
                    Image(item.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .clipped()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .shadow(radius: 4)
                    }
                    .padding(.top, 40) // safe area adjustment
                }
                
                // Content
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        Text(item.title.replacingOccurrences(of: "\n", with: " "))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 24)
                    
                    Divider()
                    
                    if isGenerating {
                        VStack(alignment: .center, spacing: 16) {
                            Spacer().frame(height: 40)
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("AI is analyzing local insights...")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .onAppear {
                            simulateGeneration()
                        }
                    } else {
                        // Generated Text with a nice reveal animation
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.purple)
                                Text("AI Generated Insights")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.purple)
                            }
                            
                            Text(generatedText)
                                .font(.body)
                                .lineSpacing(6)
                                .foregroundColor(.primary)
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .top)
    }
    
    private func simulateGeneration() {
        // Simulate a 2-second network call to the "Foundation Model"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isGenerating = false
                generatedText = simulatedAIResponse
            }
        }
    }
}
