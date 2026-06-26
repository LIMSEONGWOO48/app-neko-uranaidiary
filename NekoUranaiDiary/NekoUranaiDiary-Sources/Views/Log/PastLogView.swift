import SwiftUI
import SwiftData

struct PastLogView: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \DailyLog.date, order: .reverse) private var allLogs: [DailyLog]

    private var profile: UserProfile? { profiles.first }

    private var visibleLogs: [DailyLog] {
        guard let profile else { return [] }
        return LogFilter.visibleLogs(
            from: allLogs,
            userId: profile.userId,
            planType: profile.planTypeEnum
        )
    }

    var body: some View {
        Group {
            if visibleLogs.isEmpty {
                ContentUnavailableView(
                    "ログがありません",
                    systemImage: "book.closed",
                    description: Text("占いを見ると、ここに記録が残るにゃ。")
                )
            } else {
                List(visibleLogs) { log in
                    logRow(log)
                }
            }
        }
        .navigationTitle("過去ログ")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                AdBannerView()

                if profile?.planTypeEnum == .free {
                    Text("無料プランは直近\(LogFilter.freePlanVisibleDays)日分まで表示されます")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(AppTheme.backgroundGradientBottom)
                }
            }
        }
    }

    private func logRow(_ log: DailyLog) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(log.date, format: .dateTime.year().month().day())
                    .font(.headline)
                Spacer()
                Text("\(log.moodEnum.emoji) \(log.moodEnum.rawValue)")
                    .font(.subheadline)
            }

            Text(log.concernCategoryEnum.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.accent.opacity(0.15))
                .clipShape(Capsule())

            if let memo = log.memo, !memo.isEmpty {
                Text(memo)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            HStack(spacing: 12) {
                scoreLabel("総合", log.totalScore)
                scoreLabel("恋愛", log.loveScore)
                scoreLabel("仕事", log.workScore)
                scoreLabel("金運", log.moneyScore)
            }

            Text(log.fortuneText)
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text("ラッキー行動: \(log.luckyAction)")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(.vertical, 4)
    }

    private func scoreLabel(_ title: String, _ score: Int) -> some View {
        HStack(spacing: 2) {
            Text(title)
                .font(.caption2)
            Text("\(score)")
                .font(.caption.bold())
        }
        .foregroundStyle(AppTheme.accent)
    }
}

#Preview {
    NavigationStack {
        PastLogView()
    }
    .modelContainer(for: [UserProfile.self, DailyLog.self], inMemory: true)
}
