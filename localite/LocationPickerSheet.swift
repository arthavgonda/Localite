import SwiftUI
import MapKit

struct LocationPickerSheet: View {
    @EnvironmentObject private var locationStore: LocationStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    liveCard
                    presetSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 40)
            }
        }
        .background(Color.white)
    }

    private var headerBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.black.opacity(0.15))
                .frame(width: 36, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
                .padding(.bottom, 8)

            Text("Deliver to")
                .font(.title2.weight(.bold))
                .foregroundStyle(LocaliteTheme.ink)
                .padding(.horizontal, 20)

            Text("Choose where to discover local products")
                .font(.subheadline)
                .foregroundStyle(LocaliteTheme.inkMuted)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
    }

    private var liveCard: some View {
        Button {
            locationStore.requestLiveLocation { _ in dismiss() }
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 0.18, green: 0.62, blue: 0.27),
                            Color(red: 0.12, green: 0.45, blue: 0.20)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .frame(width: 52, height: 52)

                    if locationStore.isResolvingLive {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "location.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Use current location")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(LocaliteTheme.ink)
                    Text("GPS · updates automatically")
                        .font(.caption)
                        .foregroundStyle(LocaliteTheme.inkMuted)
                }

                Spacer()

                if locationStore.selected.isLive {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.18, green: 0.55, blue: 0.24).opacity(0.12))
                            .frame(width: 28, height: 28)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(red: 0.18, green: 0.55, blue: 0.24))
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(locationStore.selected.isLive
                          ? Color(red: 0.18, green: 0.55, blue: 0.24).opacity(0.06)
                          : LocaliteTheme.surfaceMuted)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        locationStore.selected.isLive
                            ? Color(red: 0.18, green: 0.55, blue: 0.24).opacity(0.3)
                            : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var presetSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SAVED LOCATIONS")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(LocaliteTheme.inkMuted)
                .tracking(1.2)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                ForEach(Array(AppLocation.presets.enumerated()), id: \.element.id) { index, loc in
                    presetRow(loc, isLast: index == AppLocation.presets.count - 1)
                }
            }
            .background(LocaliteTheme.surfaceMuted, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private func presetRow(_ loc: AppLocation, isLast: Bool) -> some View {
        let isSelected = locationStore.selected.id == loc.id && !locationStore.selected.isLive

        return Button {
            locationStore.selected = loc
            dismiss()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isSelected ? LocaliteTheme.accent : Color.white)
                        .frame(width: 40, height: 40)
                        .shadow(color: .black.opacity(isSelected ? 0 : 0.06), radius: 4, y: 2)

                    Image(systemName: "mappin")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(isSelected ? .white : LocaliteTheme.inkMuted)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(loc.shortName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(LocaliteTheme.ink)
                    Text(loc.name)
                        .font(.caption)
                        .foregroundStyle(LocaliteTheme.inkMuted)
                        .lineLimit(1)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(LocaliteTheme.accent)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            if !isLast {
                Rectangle()
                    .fill(Color.black.opacity(0.07))
                    .frame(height: 0.5)
                    .padding(.leading, 70)
            }
        }
    }
}
