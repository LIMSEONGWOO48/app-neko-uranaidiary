import SwiftUI

struct LoadingOverlay: View {
    let message: String

    var body: some View {
        ZStack {
            AppTheme.accentDark.opacity(0.25)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                MeowAvatarView(size: 56, showGlow: true)
                ProgressView()
                    .tint(AppTheme.accent)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(24)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(AppTheme.cardBorder, lineWidth: 1)
            }
            .shadow(color: AppTheme.accent.opacity(0.2), radius: 12, y: 4)
        }
    }
}
