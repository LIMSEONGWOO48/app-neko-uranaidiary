import Foundation

struct CatCardResult: Identifiable, Hashable {
    let id = UUID()
    let cardName: String
    let cardEmoji: String
    let theme: String
    let fortune: FortuneResult
}

enum CatCardGenerator {
    private static let cards: [(name: String, emoji: String, theme: String)] = [
        ("みけ猫", "🐱", "好奇心"),
        ("しろ猫", "😺", "やさしさ"),
        ("くろ猫", "🐈‍⬛", "直感"),
        ("トラ猫", "🐯", "チャレンジ"),
        ("ペルシャ猫", "😸", "ゆったり"),
        ("サバ猫", "😽", "信頼")
    ]

    static func generate(profile: UserProfile) -> CatCardResult {
        let seed = dailySeed(birthday: profile.birthday, userId: profile.userId)
        var generator = SeededRandomNumberGenerator(seed: seed)

        let card = cards.randomElement(using: &generator) ?? cards[0]
        let local = FortuneGenerator.generateLocal(
            mood: .good,
            category: profile.concernCategoryEnum,
            memo: nil,
            birthday: profile.birthday
        )

        let themedMessage = """
        今日の\(card.theme)がキーワードにゃ。\
        \(local.fallbackFortuneText)
        """

        let fortune = FortuneResult(
            totalScore: local.totalScore,
            loveScore: local.loveScore,
            workScore: local.workScore,
            moneyScore: local.moneyScore,
            fortuneText: themedMessage,
            luckyAction: local.luckyAction,
            oneLiner: "今日の守護猫は\(card.name)にゃ"
        )

        return CatCardResult(
            cardName: card.name,
            cardEmoji: card.emoji,
            theme: card.theme,
            fortune: fortune
        )
    }

    private static func dailySeed(birthday: Date, userId: String) -> UInt64 {
        let day = UInt64(Calendar.current.startOfDay(for: .now).timeIntervalSince1970)
        let birthDay = UInt64(Calendar.current.startOfDay(for: birthday).timeIntervalSince1970)
        let userHash = stableHash(userId)
        return day ^ birthDay ^ userHash ^ 0xCA7CAFE
    }

    private static func stableHash(_ value: String) -> UInt64 {
        var hash: UInt64 = 5381
        for byte in value.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(byte)
        }
        return hash
    }
}

private struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 0xDEADBEEF : seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_847_093_229 &+ 1_446_600_688_903_907_237
        return state
    }
}
