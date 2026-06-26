import Foundation

struct FortuneResult: Identifiable, Hashable {
    let id = UUID()
    let totalScore: Int
    let loveScore: Int
    let workScore: Int
    let moneyScore: Int
    let fortuneText: String
    let luckyAction: String
    let oneLiner: String
}

struct DailyLogSummary: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let mood: Mood
    let concernCategory: ConcernCategory
    let memo: String?
    let fortuneText: String
}

struct ChatBubble: Identifiable, Hashable {
    let id = UUID()
    let role: ChatRole
    let message: String
    let createdAt: Date
}

enum DummyData {
    static let sampleFortune = FortuneResult(
        totalScore: 4,
        loveScore: 3,
        workScore: 4,
        moneyScore: 5,
        fortuneText: "今日はゆっくり自分のペースを大切にするにゃ。小さな幸せに気づける一日になりそうだにゃ。",
        luckyAction: "お気に入りの飲み物をゆっくり味わう",
        oneLiner: "焦らなくて大丈夫にゃ。"
    )

    static let sampleChatMessages: [ChatBubble] = [
        ChatBubble(
            role: .user,
            message: "彼氏と喧嘩した",
            createdAt: .now.addingTimeInterval(-300)
        ),
        ChatBubble(
            role: .assistant,
            message: "今日はすぐに結論を出さなくても大丈夫にゃ。まずは自分がどう感じたかを整理してみるにゃ。",
            createdAt: .now.addingTimeInterval(-240)
        )
    ]

    static let sampleLogs: [DailyLogSummary] = [
        DailyLogSummary(
            date: .now,
            mood: .anxious,
            concernCategory: .love,
            memo: "連絡が来なくて不安",
            fortuneText: "感情を正直に伝えると、関係が少しずつ前に進むにゃ。"
        ),
        DailyLogSummary(
            date: .now.addingTimeInterval(-86400),
            mood: .tired,
            concernCategory: .work,
            memo: "残業が続いている",
            fortuneText: "休息も仕事の一部にゃ。今夜は早めに休むのがラッキー行動にゃ。"
        ),
        DailyLogSummary(
            date: .now.addingTimeInterval(-86400 * 2),
            mood: .good,
            concernCategory: .selfGrowth,
            memo: nil,
            fortuneText: "小さな一歩が、大きな自信につながるにゃ。"
        )
    ]

    static let premiumMonthlyPrice = "¥480/月"
    static let ticketPrice = "¥160"
}
