import SwiftUI

struct PNREntryView: View {
    @ObservedObject var viewModel: ExploreViewModel
    @Binding var detent: PresentationDetent
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Top section wrapped to match the exact 190 sheet detent height
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Button(action: {
                        viewModel.clearJourney()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                            .padding(10)
                            .background(Color(UIColor.systemGray5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Enter PNR")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.searchJourney()
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }) {
                        Image(systemName: "checkmark")
                            .foregroundColor(viewModel.isValidPNR ? .white : .gray.opacity(0.5))
                            .padding(10)
                            .background(viewModel.isValidPNR ? Color.blue : Color(UIColor.systemGray5))
                            .clipShape(Circle())
                    }
                    .disabled(!viewModel.isValidPNR)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Journey Details")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter PNR", text: $viewModel.pnrInput)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                    
                    if viewModel.showError {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding()
                
                Spacer(minLength: 0) // Push everything to the top
            }
            .frame(height: 190) // Exactly matches the ExploreView detent to perfectly hide the list below!
            
            // Expanded List Content
            if let journey = viewModel.currentJourney {
                Divider()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Where do you want your items delivered?")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        ForEach(journey.stations) { station in
                            StationRow(station: station)
                            Divider().padding(.leading, 70)
                        }
                    }
                    .padding(.top, 40)

                    .padding(.bottom, 40)
                }
            } else {
                Spacer()
            }
        }
        .background(Color.white)
    }
}

struct StationRow: View {
    let station: Station
    
    var body: some View {
        HStack(spacing: 16) {
            // Logo Circle mimicking IRCTC / Food app
            ZStack {
                Circle()
                    .stroke(Color.red.opacity(0.8), lineWidth: 3)
                    .frame(width: 44, height: 44)
                Circle()
                    .fill(Color.blue)
                    .frame(width: 36, height: 36)
                Text(station.code)
                    .font(.caption2).bold()
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(station.name)
                    .font(.headline)
                Text("\(station.arrivalTime)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
    }
}
