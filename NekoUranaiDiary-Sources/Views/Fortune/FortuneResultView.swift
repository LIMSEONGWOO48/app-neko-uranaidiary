import SwiftUI
import SwiftData

struct FortuneResultView: View {
    let fortune: FortuneResult

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CatCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("今日の一言")
                            .font(.headline)
                        Text(fortune.oneLiner)
                            .font(.title3.bold())
                    }
                }

                scoreCard(title: "総合運", score: fortune.totalScore)
                scoreCard(title: "恋愛運", score: fortune.loveScore)
                scoreCard(title: "仕事運", score: fortune.workScore)
                scoreCard(title: "金運", score: fortune.moneyScore)

                CatCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("猫占い師からのメッセージ")
                            .font(.headline)
                        Text(fortune.fortuneText)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }

                CatCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ラッキー行動")
                            .font(.headline)
                        Text(fortune.luckyAction)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }
            }
            .padding(20)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("占い結果")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AdBannerView()
        }
    }

    private func scoreCard(title: String, score: Int) -> some View {
        CatCard {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                ScoreStarsView(score: score)
            }
        }
    }
}

#Preview {
    NavigationStack {
        FortuneResultView(fortune: DummyData.sampleFortune)
    }
    .modelContainer(for: [UserProfile.self], inMemory: true)
}
