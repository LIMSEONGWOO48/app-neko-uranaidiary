import SwiftUI

enum AppTheme {
    static let accent = Color(red: 0.95, green: 0.55, blue: 0.35)
    static let background = Color(red: 0.99, green: 0.97, blue: 0.94)
    static let cardBackground = Color.white
    static let secondaryText = Color.secondary
}

struct CatCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

struct ScoreStarsView: View {
    let score: Int
    let maxScore: Int = 5

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxScore, id: \.self) { index in
                Image(systemName: index <= score ? "star.fill" : "star")
                    .foregroundStyle(index <= score ? AppTheme.accent : .gray.opacity(0.3))
            }
        }
    }
}
