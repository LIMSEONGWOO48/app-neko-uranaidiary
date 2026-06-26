import SwiftUI
import SwiftData

/// 無料プラン向けの広告バナー枠。
/// AdMob 連携時は `AdBannerPlaceholderView` を実広告ビューに差し替える。
struct AdBannerView: View {
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        if AdService.shouldShowAds(for: profile) {
            AdBannerPlaceholderView()
        }
    }
}

struct AdBannerPlaceholderView: View {
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "megaphone")
                    .font(.caption)
                Text("広告")
                    .font(.caption2.bold())
            }
            .foregroundStyle(AppTheme.secondaryText)

            Text("準備中")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: AdService.bannerHeight)
        .background(AppTheme.cardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .foregroundStyle(Color.gray.opacity(0.3))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppTheme.backgroundGradientBottom)
        .accessibilityLabel("広告枠、準備中")
    }
}

#Preview("無料ユーザー") {
  AdBannerPlaceholderView()
}

#Preview("プレミアムで非表示") {
  AdBannerView()
    .modelContainer(for: [UserProfile.self], inMemory: true)
}
