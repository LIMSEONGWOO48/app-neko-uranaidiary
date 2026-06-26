import SwiftUI
import SwiftData

struct HomeHubView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var allUsageLimits: [UsageLimit]

    @State private var path = NavigationPath()
    @State private var todayCard: CatCardResult?

    private var profile: UserProfile? { profiles.first }

    private var usageStatus: UsageStatus? {
        guard let profile, let usageLimit else { return nil }
        return UsageLimitService.status(profile: profile, usage: usageLimit)
    }

    private var usageLimit: UsageLimit? {
        guard let profile else { return nil }
        return allUsageLimits.first { $0.userId == profile.userId }
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    catCardSection
                    modesSection
                    quickActionsSection
                }
                .padding(20)
            }
            .background(AppTheme.screenBackground)
            .navigationTitle("猫占い日記")
            .toolbarBackground(AppTheme.backgroundGradientTop.opacity(0.95), for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .onAppear {
                ensureUsageLimit()
                loadTodayCard()
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .moodFortune:
                    MoodFortuneView(path: $path)
                case .catCard:
                    CatCardDrawView(path: $path)
                case .fortune(let fortune):
                    FortuneResultView(
                        fortune: fortune,
                        onGoHome: { path = NavigationPath() }
                    )
                case .chat:
                    ChatConsultationView()
                case .logs:
                    PastLogView()
                case .paywall:
                    PaywallView()
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                AdBannerView()
            }
        }
    }

    private var headerSection: some View {
        CatCard {
            HStack(alignment: .top, spacing: 14) {
                MeowAvatarView(size: 72)

                VStack(alignment: .leading, spacing: 8) {
                    if let profile {
                        Text("おかえりにゃ、\(profile.nickname) 🐾")
                            .font(.title3.bold())
                            .foregroundStyle(AppTheme.accentDark)
                    }

                    Text(MeowCharacter.greeting)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.accent)

                    Text("今日も1分だけ、自分と向き合う時間にゃ。")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)

                    if let profile {
                        Text("誕生日: \(profile.birthday, format: .dateTime.month().day())")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.gold)
                    }
                }
            }
        }
    }

    private var catCardSection: some View {
        CatCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("今日の猫カード")
                        .font(.headline)
                    Spacer()
                    Text("1日1回")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.accent.opacity(0.15))
                        .clipShape(Capsule())
                }

                Text("誕生日と今日の日付から、あなた専用の猫カードが決まるにゃ。")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)

                if let todayCard {
                    HStack(spacing: 12) {
                        Text(todayCard.cardEmoji)
                            .font(.system(size: 40))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(todayCard.cardName)
                                .font(.headline)
                            Text("キーワード: \(todayCard.theme)")
                                .font(.caption)
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                    }

                    Button("カードの結果を見る") {
                        path.append(AppRoute.fortune(todayCard.fortune))
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(AppTheme.accent)
                }

                PrimaryButton(title: todayCard == nil ? "猫カードを引く" : "もう一度カードを見る") {
                    path.append(AppRoute.catCard)
                }
            }
        }
    }

    private var modesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("占いモード")
                .font(.headline)

            modeRow(
                icon: "heart.text.square.fill",
                title: "気分で占う",
                subtitle: "今日の気分・悩みに合わせた占い"
            ) {
                path.append(AppRoute.moodFortune)
            }

            modeRow(
                icon: "sparkles",
                title: "AI猫占い相談",
                subtitle: chatSubtitle
            ) {
                if usageStatus?.canChat == true {
                    path.append(AppRoute.chat)
                } else {
                    path.append(AppRoute.paywall)
                }
            }
        }
    }

    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            modeRow(
                icon: "book.fill",
                title: "過去ログ",
                subtitle: logSubtitle
            ) {
                path.append(AppRoute.logs)
            }

            modeRow(
                icon: "crown.fill",
                title: "プレミアムプラン",
                subtitle: DummyData.premiumMonthlyPrice
            ) {
                path.append(AppRoute.paywall)
            }
        }
    }

    private var chatSubtitle: String {
        guard let usageStatus else { return "残り 0 回" }
        if usageStatus.canChat {
            return "残り \(usageStatus.remainingChats) 回"
        }
        return "回数上限 — プランを確認"
    }

    private var logSubtitle: String {
        if profile?.planTypeEnum == .premium {
            return "すべての記録を閲覧"
        }
        return "直近\(LogFilter.freePlanVisibleDays)日まで（無料）"
    }

    private func ensureUsageLimit() {
        guard let profile else { return }
        _ = UsageLimitService.resolve(context: modelContext, userId: profile.userId)
    }

    private func loadTodayCard() {
        guard let profile else { return }
        todayCard = CatCardGenerator.generate(profile: profile)
    }

    private func modeRow(
        icon: String,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(AppTheme.accent)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeHubView()
        .modelContainer(for: [UserProfile.self, DailyLog.self, UsageLimit.self], inMemory: true)
}
