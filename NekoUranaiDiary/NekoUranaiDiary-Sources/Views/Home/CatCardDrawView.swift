import SwiftUI
import SwiftData

struct CatCardDrawView: View {
    @Binding var path: NavigationPath
    @Query private var profiles: [UserProfile]

    @State private var deck: [CatCardResult] = []
    @State private var deckTitle = "今日の五枚"
    @State private var selectedIndex: Int?
    @State private var isRevealed = false
    @State private var card: CatCardResult?

    private var profile: UserProfile? { profiles.first }

    private let fanRotations: [Double] = [-10, -5, 0, 5, 10]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                MeowHeroView(maxHeight: 260)
                    .padding(.top, 8)

                if isRevealed, let card {
                    revealedSection(card: card)
                } else {
                    selectionSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.screenBackground)
        .navigationTitle("猫カード")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadDeck)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AdBannerView()
        }
    }

    private var selectionSection: some View {
        VStack(spacing: 20) {
            Text(deckTitle)
                .font(.subheadline.bold())
                .foregroundStyle(AppTheme.accent)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(AppTheme.accent.opacity(0.12))
                .clipShape(Capsule())

            MeowSpeechBubble(text: "今日だけのデッキにゃ。気になるカードを1枚選んでにゃ！")

            HStack(spacing: -18) {
                ForEach(Array(deck.enumerated()), id: \.offset) { index, _ in
                    Button {
                        selectCard(at: index)
                    } label: {
                        TarotCardBackView(
                            index: index,
                            isSelected: selectedIndex == index,
                            isDimmed: selectedIndex != nil && selectedIndex != index
                        )
                    }
                    .buttonStyle(.plain)
                    .rotationEffect(.degrees(fanRotation(for: index)))
                    .zIndex(selectedIndex == index ? 10 : Double(index))
                    .disabled(selectedIndex != nil)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)

            Text("タップして1枚選ぶにゃ")
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
        }
    }

    private func revealedSection(card: CatCardResult) -> some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                Text(card.cardEmoji)
                    .font(.system(size: 72))
                    .transition(.scale.combined(with: .opacity))

                Text(card.cardName)
                    .font(.title.bold())

                Text("今日のキーワード: \(card.theme)")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.accent)

                Text(card.fortune.oneLiner)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(AppTheme.cardBorder, lineWidth: 1)
            }

            VStack(spacing: 12) {
                PrimaryButton(title: "占い結果を詳しく見る") {
                    path.append(AppRoute.fortune(card.fortune))
                }

                Button("ホームに戻る") {
                    path = NavigationPath()
                }
                .foregroundStyle(AppTheme.accent)
            }
        }
    }

    private func fanRotation(for index: Int) -> Double {
        guard index < fanRotations.count else { return 0 }
        return fanRotations[index]
    }

    private func loadDeck() {
        guard let profile else { return }
        deckTitle = CatCardGenerator.deckTitle(profile: profile)
        deck = CatCardGenerator.generateDeck(profile: profile)

        if let saved = CatCardSelectionStore.load(userId: profile.userId),
           saved >= 0, saved < deck.count {
            selectedIndex = saved
            card = deck[saved]
            isRevealed = true
        }
    }

    private func selectCard(at index: Int) {
        guard let profile, index < deck.count, selectedIndex == nil else { return }

        selectedIndex = index
        card = deck[index]
        CatCardSelectionStore.save(userId: profile.userId, index: index)

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
