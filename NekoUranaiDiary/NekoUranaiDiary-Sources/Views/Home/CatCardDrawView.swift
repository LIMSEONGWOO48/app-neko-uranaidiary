import SwiftUI
import SwiftData

struct CatCardDrawView: View {
    @Binding var path: NavigationPath
    @Query private var profiles: [UserProfile]

    @State private var isRevealed = false
    @State private var card: CatCardResult?

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            if let card, isRevealed {
                VStack(spacing: 16) {
                    Text(card.cardEmoji)
                        .font(.system(size: 80))
                        .transition(.scale.combined(with: .opacity))

                    Text(card.cardName)
                        .font(.title.bold())

                    Text("今日のキーワード: \(card.theme)")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.accent)

                    Text(card.fortune.oneLiner)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else {
                VStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppTheme.cardGradient)
                        .frame(width: 200, height: 280)
                        .overlay {
                            VStack(spacing: 10) {
                                MeowAvatarView(size: 72, showGlow: false)
                                Text("Tap!")
                                    .font(.caption.bold())
                                    .foregroundStyle(.white.opacity(0.95))
                                Image(systemName: "sparkles")
                                    .foregroundStyle(AppTheme.gold)
                            }
                        }
                        .shadow(color: AppTheme.accent.opacity(0.35), radius: 12, y: 6)

                    Text("タップして猫カードを開くにゃ")
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }

            Spacer()

            if isRevealed, let card {
                VStack(spacing: 12) {
                    PrimaryButton(title: "占い結果を詳しく見る") {
                        path.append(AppRoute.fortune(card.fortune))
                    }

                    Button("ホームに戻る") {
                        path = NavigationPath()
                    }
                    .foregroundStyle(AppTheme.accent)
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.screenBackground)
        .navigationTitle("猫カード")
        .navigationBarTitleDisplayMode(.inline)
        .contentShape(Rectangle())
        .onTapGesture {
            revealCard()
        }
        .onAppear {
            if card == nil, let profile {
                card = CatCardGenerator.generate(profile: profile)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AdBannerView()
        }
    }

    private func revealCard() {
        guard !isRevealed else { return }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isRevealed = true
        }
    }
}

#Preview {
    NavigationStack {
        CatCardDrawView(path: .constant(NavigationPath()))
    }
    .modelContainer(for: [UserProfile.self], inMemory: true)
}
