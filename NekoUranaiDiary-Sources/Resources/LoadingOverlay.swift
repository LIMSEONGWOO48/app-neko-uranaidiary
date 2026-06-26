import SwiftUI

struct LoadingOverlay: View {
    let message: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                ProgressView()
                    .tint(AppTheme.accent)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(24)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 8)
        }
    }
}
