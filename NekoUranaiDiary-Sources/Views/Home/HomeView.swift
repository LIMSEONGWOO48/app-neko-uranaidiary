import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \DailyLog.date, order: .reverse) private var allLogs: [DailyLog]
    @Query private var allUsageLimits: [UsageLimit]

    @State private var selectedMood: Mood = .normal
    @State private var selectedCategory: ConcernCategory = .love
    @State private var memo = ""
    @State private var currentFortune: FortuneResult?
    @State private var showFortune = false
    @State private var showChat = false
    @State private var showLogs = false
    @State private var showPaywall = false
    @State private var isGeneratingFortune = false
    @State private var limitMessage: String?

    private var profile: UserProfile? { profiles.first }

    private var usageLimit: UsageLimit? {
        guard let profile else { return nil }
        return allUsageLimits.first { $0.userId == profile.userId }
    }

    private var usageStatus: UsageStatus? {
        guard let profile, let usageLimit else { return nil }
        return UsageLimitService.status(profile: profile, usage: usageLimit)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    moodSection
                    categorySection
                    memoSection
                    fortuneSection
                    quickActionsSection
                }
                .padding(20)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("今日の猫占い")
            .onAppear {
                ensureUsageLimit()
                loadTodayInputIfNeeded()
            }
            .navigationDestination(isPresented: $showFortune) {
                if let currentFortune {
                    FortuneResultView(fortune: currentFortune)
                }
            }
            .navigationDestination(isPresented: $showChat) {
                ChatConsultationView()
            }
            .navigationDestination(isPresented: $showLogs) {
                PastLogView()
            }
            .navigationDestination(isPresented: $showPaywall) {
                PaywallView()
            }
            .overlay {
                if isGeneratingFortune {
                    LoadingOverlay(message: "猫占い師が占い中にゃ...")
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                AdBannerView()
            }
        }
    }

    private var headerSection: some View {
        CatCard {
            VStack(alignment: .leading, spacing: 8) {
                if let profile {
                    Text("おかえりにゃ、\(profile.nickname) 🐾")
                        .font(.headline)
                } else {
                    Text("おかえりにゃ 🐾")
                        .font(.headline)
                }
                Text("今日の気分と悩みを教えてにゃ。")
                    .foregroundStyle(AppTheme.secondaryText)

                if let usageStatus {
                    Text(usageStatus.fortuneLimitMessage)
                        .font(.caption)
                        .foregroundStyle(AppTheme.accent)
                }
            }
        }
    }

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日の気分")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(Mood.allCases) { mood in
                    Button {
                        selectedMood = mood
                    } label: {
                        VStack(spacing: 6) {
                            Text(mood.emoji)
                                .font(.title2)
                            Text(mood.rawValue)
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedMood == mood
                                ? AppTheme.accent.opacity(0.2)
                                : AppTheme.cardBackground
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    selectedMood == mood ? AppTheme.accent : .clear,
                                    lineWidth: 2
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("悩みジャンル")
                .font(.headline)
            Picker("悩みジャンル", selection: $selectedCategory) {
                ForEach(ConcernCategory.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var memoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("一言メモ（任意）")
                .font(.headline)
            TextField("今日のことをひとこと...", text: $memo, axis: .vertical)
                .lineLimit(3...5)
                .padding(12)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var fortuneSection: some View {
        VStack(spacing: 8) {
            PrimaryButton(title: fortuneButtonTitle) {
                Task {
                    await performFortune()
                }
            }
            .disabled(isGeneratingFortune || !(usageStatus?.canFortune ?? true))
            .opacity(isGeneratingFortune || !(usageStatus?.canFortune ?? true) ? 0.6 : 1)

            if let limitMessage {
                Text(limitMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            } else if usageStatus?.canFortune == false {
                Button("プレミアムで回数を増やす") {
                    showPaywall = true
                }
                .font(.caption)
                .foregroundStyle(AppTheme.accent)
            }
        }
    }

    private var fortuneButtonTitle: String {
        if usageStatus?.canFortune == false {
            return "今日の占い回数上限に達しました"
        }
        return todayLog != nil ? "今日の占いをもう一度見る" : "今日の占いを見る"
    }

    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            actionRow(
                icon: "bubble.left.and.bubble.right.fill",
                title: "AI猫占い相談",
                subtitle: chatSubtitle
            ) {
                if usageStatus?.canChat == true {
                    showChat = true
                } else {
                    showPaywall = true
                }
            }

            actionRow(
                icon: "book.fill",
                title: "過去ログ",
                subtitle: logSubtitle
            ) {
                showLogs = true
            }

            actionRow(
                icon: "crown.fill",
                title: "プレミアムプラン",
                subtitle: DummyData.premiumMonthlyPrice
            ) {
                showPaywall = true
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

    private var todayLog: DailyLog? {
        guard let profile else { return nil }
        let startOfToday = LogFilter.startOfToday()
        return allLogs.first { log in
            log.userId == profile.userId && Calendar.current.isDate(log.date, inSameDayAs: startOfToday)
        }
    }

    private func ensureUsageLimit() {
        guard let profile else { return }
        _ = UsageLimitService.resolve(context: modelContext, userId: profile.userId)
    }

    private func loadTodayInputIfNeeded() {
        guard let profile else { return }
        selectedCategory = profile.concernCategoryEnum

        guard let todayLog else { return }
        selectedMood = todayLog.moodEnum
        selectedCategory = todayLog.concernCategoryEnum
        memo = todayLog.memo ?? ""
    }

    private func performFortune() async {
        guard let profile, !isGeneratingFortune else { return }

        limitMessage = nil
        let usage = UsageLimitService.resolve(context: modelContext, userId: profile.userId)
        let status = UsageLimitService.status(profile: profile, usage: usage)

        guard status.canFortune else {
            limitMessage = status.fortuneLimitMessage
            return
        }

        let trimmedMemo = memo.trimmingCharacters(in: .whitespacesAndNewlines)
        let memoValue = trimmedMemo.isEmpty ? nil : trimmedMemo

        if let todayLog, inputsMatchTodayLog(todayLog, memo: memoValue) {
            currentFortune = todayLog.asFortuneResult
            showFortune = true
            return
        }

        isGeneratingFortune = true
        defer { isGeneratingFortune = false }

        guard UsageLimitService.consumeFortune(profile: profile, usage: usage) else {
            limitMessage = status.fortuneLimitMessage
            return
        }
        try? modelContext.save()

        let fortune = await FortuneComposer.generate(
            profile: profile,
            mood: selectedMood,
            category: selectedCategory,
            memo: memoValue
        )

        saveDailyLog(
            profile: profile,
            fortune: fortune,
            memo: memoValue
        )

        currentFortune = fortune
        showFortune = true
    }

    private func saveDailyLog(
        profile: UserProfile,
        fortune: FortuneResult,
        memo: String?
    ) {
        let startOfToday = LogFilter.startOfToday()

        if let existing = todayLog {
            existing.mood = selectedMood.rawValue
            existing.concernCategory = selectedCategory.rawValue
            existing.memo = memo
            existing.fortuneText = fortune.fortuneText
            existing.totalScore = fortune.totalScore
            existing.loveScore = fortune.loveScore
            existing.workScore = fortune.workScore
            existing.moneyScore = fortune.moneyScore
            existing.luckyAction = fortune.luckyAction
            existing.createdAt = .now
        } else {
            let log = DailyLog(
                userId: profile.userId,
                date: startOfToday,
                mood: selectedMood,
                concernCategory: selectedCategory,
                memo: memo,
                fortuneText: fortune.fortuneText,
                totalScore: fortune.totalScore,
                loveScore: fortune.loveScore,
                workScore: fortune.workScore,
                moneyScore: fortune.moneyScore,
                luckyAction: fortune.luckyAction
            )
            modelContext.insert(log)
        }

        try? modelContext.save()
    }

    private func inputsMatchTodayLog(_ log: DailyLog, memo: String?) -> Bool {
        log.moodEnum == selectedMood
            && log.concernCategoryEnum == selectedCategory
            && (log.memo ?? "") == (memo ?? "")
    }

    private func actionRow(
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
    HomeView()
        .modelContainer(for: [UserProfile.self, DailyLog.self, UsageLimit.self], inMemory: true)
}
