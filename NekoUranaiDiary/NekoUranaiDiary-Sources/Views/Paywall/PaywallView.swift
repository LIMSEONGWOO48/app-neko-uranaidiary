import SwiftUI
import SwiftData

struct PaywallView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var allUsageLimits: [UsageLimit]

    @State private var feedbackMessage: String?

    private var profile: UserProfile? { profiles.first }

    private var usageLimit: UsageLimit? {
        guard let profile else { return nil }
        return allUsageLimits.first { $0.userId == profile.userId }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("プレミアムプラン")
                        .font(.title.bold())
                    Text("もっと猫占い師と相談したいあなたにゃ。")
                        .foregroundStyle(AppTheme.secondaryText)

                    if let profile {
                        Text("現在のプラン: \(profile.planTypeEnum.displayName)")
                            .font(.caption)
                            .foregroundStyle(AppTheme.accent)
                    }
                }

                CatCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("月額プレミアム")
                                .font(.headline)
                            Spacer()
                            Text(DummyData.premiumMonthlyPrice)
                                .font(.title3.bold())
                                .foregroundStyle(AppTheme.accent)
                        }

                        Divider()

                        benefitRow("AI相談 月\(PlanLimits.premiumChatMonthly)回")
                        benefitRow("広告なし")
                        benefitRow("占い 1日\(PlanLimits.premiumFortuneDaily)回")
                        benefitRow("過去ログ 無制限")

                        PrimaryButton(title: "プレミアムに加入する") {
                            activatePremiumForTesting()
                        }
                    }
                }

                CatCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("相談追加チケット")
                                .font(.headline)
                            Spacer()
                            Text(DummyData.ticketPrice)
                                .font(.title3.bold())
                                .foregroundStyle(AppTheme.accent)
                        }

                        Text("相談\(PlanLimits.ticketChatAmount)回分を追加できます。")
                            .foregroundStyle(AppTheme.secondaryText)

                        if let usageLimit {
                            Text("所持チケット: \(usageLimit.ticketBalance) 回分")
                                .font(.caption)
                                .foregroundStyle(AppTheme.secondaryText)
                        }

                        PrimaryButton(title: "チケットを購入する") {
                            grantTicketsForTesting()
                        }
                    }
                }

                if let feedbackMessage {
                    Text(feedbackMessage)
                        .font(.caption)
                        .foregroundStyle(AppTheme.accent)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                Text("※ StoreKit 課金は Phase5 で実装予定です。上のボタンは開発・テスト用です。")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(20)
        }
        .background(AppTheme.screenBackground)
        .navigationTitle("課金")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            ensureUsageLimit()
        }
    }

    private func benefitRow(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppTheme.accent)
            Text(text)
        }
    }

    private func ensureUsageLimit() {
        guard let profile else { return }
        _ = UsageLimitService.resolve(context: modelContext, userId: profile.userId)
    }

    private func activatePremiumForTesting() {
        guard let profile else { return }
        profile.planType = PlanType.premium.rawValue
        try? modelContext.save()
        feedbackMessage = "プレミアムプランを有効にしました（テスト用）"
    }

    private func grantTicketsForTesting() {
        guard let profile else { return }
        let usage = UsageLimitService.resolve(context: modelContext, userId: profile.userId)
        UsageLimitService.grantTickets(usage: usage)
        try? modelContext.save()
        feedbackMessage = "チケット\(PlanLimits.ticketChatAmount)回分を付与しました（テスト用）"
    }
}

#Preview {
    NavigationStack {
        PaywallView()
    }
    .modelContainer(for: [UserProfile.self, UsageLimit.self], inMemory: true)
}
