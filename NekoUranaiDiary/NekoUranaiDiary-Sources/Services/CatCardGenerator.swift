import Foundation

struct CatCardResult: Identifiable, Hashable {
    let deckIndex: Int
    let cardName: String
    let cardEmoji: String
    let theme: String
    let fortune: FortuneResult

    var id: String { "\(deckIndex)-\(cardName)" }
}

enum CatCardGenerator {
    static let deckSize = 5

    private static let deckTitles = [
        "星月夜の五枚",
        "ラベンダーの五枚",
        "月光の五枚",
        "黄金の五枚",
        "ほほえみの五枚",
        "みちしるべの五枚",
        "ひらめきの五枚",
        "やすらぎの五枚"
    ]

    private static let cards: [(name: String, emoji: String, theme: String)] = [
        ("みけ猫", "🐱", "好奇心"),
        ("しろ猫", "😺", "やさしさ"),
        ("くろ猫", "🐈‍⬛", "直感"),
        ("トラ猫", "🐯", "チャレンジ"),
        ("ペルシャ猫", "😸", "ゆったり"),
        ("サバ猫", "😽", "信頼"),
        ("ルナ猫", "🌙", "ひらめき"),
        ("スター猫", "⭐", "希望"),
        ("シャム猫", "🐈", "気品"),
        ("マーブル猫", "🎀", "祝福"),
        ("ミスト猫", "🌫️", "浄化"),
        ("ガーデン猫", "🌸", "成長"),
        ("クローバー猫", "🍀", "幸運"),
        ("オーロラ猫", "🌈", "変化"),
        ("パール猫", "💎", "冷静"),
        ("ソラ猫", "☁️", "自由")
    ]

    private static let themeAdvices: [String: [String]] = [
        "好奇心": [
            "知らない道を一本だけ変えてみると、いい流れが来そうにゃ。",
            "気になっていたことをひとつだけ調べると、心が軽くなるにゃ。"
        ],
        "やさしさ": [
            "誰かに優しいひと言をかけると、自分にも返ってくるにゃ。",
            "今日は完璧じゃなくても大丈夫。やさしさが開運の鍵にゃ。"
        ],
        "直感": [
            "頭で考えすぎる前に、最初に浮かんだ感覚を信じてみるにゃ。",
            "違和感を大事にする日にゃ。直感があなたを守ってるにゃ。"
        ],
        "チャレンジ": [
            "小さな一歩だけ踏み出すと、景色が変わり始めるにゃ。",
            "怖いけどやってみたいこと、今日は準備だけでも進めてみるにゃ。"
        ],
        "ゆったり": [
            "急がなくて大丈夫にゃ。呼吸を深くしてペースを落としてみるにゃ。",
            "休む時間も運気を整える大事な儀式にゃ。"
        ],
        "信頼": [
            "頼れる人に素直に話すと、道が見えてくるにゃ。",
            "約束をひとつ守るだけで、信頼運がぐっと上がるにゃ。"
        ],
        "ひらめき": [
            "ふと思いついたアイデアをメモすると、あとで効いてくるにゃ。",
            "夜に浮かんだ考えは、大切なサインかもしれないにゃ。"
        ],
        "希望": [
            "明るい未来を想像するだけで、今日の足取みが軽くなるにゃ。",
            "小さな良いことをひとつ見つけると、運気が開けるにゃ。"
        ],
        "気品": [
            "背筋を伸ばして歩くだけで、運気の流れが整うにゃ。",
            "自分を大切に扱うと、周りからも大切にされるにゃ。"
        ],
        "祝福": [
            "誰かの成功を素直に喜ぶと、自分にも祝福が返ってくるにゃ。",
            "ありがとうをひとつ多めに言う日にゃ。"
        ],
        "浄化": [
            "不要なものをひとつ手放すと、心の部屋がすっきりするにゃ。",
            "深呼吸を3回するだけで、気持ちがリセットされるにゃ。"
        ],
        "成長": [
            "小さな努力を積み重ねる日にゃ。芽はすぐには見えなくても大丈夫にゃ。",
            "昨日の自分と比べず、今日の一歩だけ見てみるにゃ。"
        ],
        "幸運": [
            "偶然の出会いを楽しむと、ラッキーが近づいてくるにゃ。",
            "笑顔で挨拶すると、思わぬ好機につながるにゃ。"
        ],
        "変化": [
            "いつもと違う選択をひとつ試すと、新しい流れが生まれるにゃ。",
            "変化は怖いけど、成長のサインにゃ。"
        ],
        "冷静": [
            "感情が動いたときほど、一度立ち止まるにゃ。",
            "急いで決めなくて大丈夫。落ち着いて選べば正解に近づくにゃ。"
        ],
        "自由": [
            "誰かの期待より、自分の気持ちを優先してみるにゃ。",
            "縛られすぎないで。心の余白が幸せを呼ぶにゃ。"
        ]
    ]

    private static let themeLuckyActions: [String: [String]] = [
        "好奇心": ["新しいお店の前を通ってみる", "未読の記事を1つだけ読む"],
        "やさしさ": ["大切な人に感謝のメッセージを送る", "好きな飲み物を誰かと分け合う"],
        "直感": ["最初に目に入った色のアイテムを身につける", "5分だけ静かに目を閉じる"],
        "チャレンジ": ["やりたいことを紙に1行書く", "いつもと違う席で作業してみる"],
        "ゆったり": ["お気に入りの音楽を1曲聴く", "早めにベッドに入る準備をする"],
        "信頼": ["久しぶりの人に様子を聞く", "約束の時間を5分前に着く"],
        "ひらめき": ["メモ帳に今の気持ちを3行書く", "窓の外の空を30秒眺める"],
        "希望": ["嬉しかったことをひとつ振り返る", "明日楽しみなことを1つ決める"],
        "気品": ["姿勢を正して5分間作業する", "お気に入りの香りを身につける"],
        "祝福": ["友達の良いニュースにリアクションする", "家族にありがとうを伝える"],
        "浄化": ["机の上をひとつだけ片づける", "シャワー後にゆっくり深呼吸する"],
        "成長": ["新しい単語や知識を1つ覚える", "最近の小さな成功をメモする"],
        "幸運": ["四つ葉のクローバーを意識して歩く", "ラッキーカラーを意識して身につける"],
        "変化": ["いつもと違う道で帰る", "新しいレシピかメニューに挑戦する"],
        "冷静": ["判断を1時間先送りにする", "水をゆっくり飲んで落ち着く"],
        "自由": ["予定をひとつ空けて自由時間を作る", "好きなことを15分だけする"]
    ]

    static func deckTitle(profile: UserProfile) -> String {
        let seed = dailySeed(birthday: profile.birthday, userId: profile.userId)
        let index = Int(seed % UInt64(deckTitles.count))
        return deckTitles[index]
    }

    static func generateDeck(profile: UserProfile) -> [CatCardResult] {
        let seed = dailySeed(birthday: profile.birthday, userId: profile.userId)
        var generator = SeededRandomNumberGenerator(seed: seed)

        let shuffled = cards.shuffled(using: &generator)
        return shuffled.prefix(deckSize).enumerated().map { index, card in
            buildResult(
                profile: profile,
                deckIndex: index,
                card: card,
                generator: &generator
            )
        }
    }

    static func generate(profile: UserProfile) -> CatCardResult {
        if let index = CatCardSelectionStore.load(userId: profile.userId) {
            let deck = generateDeck(profile: profile)
            if index < deck.count {
                return deck[index]
            }
        }
        return generateDeck(profile: profile).first!
    }

    static func card(at index: Int, profile: UserProfile) -> CatCardResult {
        let deck = generateDeck(profile: profile)
        guard index >= 0, index < deck.count else {
            return deck[0]
        }
        return deck[index]
    }

    private static func buildResult(
        profile: UserProfile,
        deckIndex: Int,
        card: (name: String, emoji: String, theme: String),
        generator: inout SeededRandomNumberGenerator
    ) -> CatCardResult {
        let cardSalt = stableHash(card.name) ^ UInt64(deckIndex &+ 1) ^ 0xCA7D0000
        let local = FortuneGenerator.generateLocal(
            mood: .good,
            category: profile.concernCategoryEnum,
            memo: nil,
            birthday: profile.birthday,
            seedSalt: cardSalt
        )

        let advices = themeAdvices[card.theme] ?? themeAdvices["希望"]!
        let advice = advices.randomElement(using: &generator) ?? advices[0]

        let actions = themeLuckyActions[card.theme] ?? themeLuckyActions["希望"]!
        let luckyAction = actions.randomElement(using: &generator) ?? actions[0]

        let themedMessage = """
        今日の\(card.theme)がキーワードにゃ。\
        \(advice)
        """

        let fortune = FortuneResult(
            totalScore: local.totalScore,
            loveScore: local.loveScore,
            workScore: local.workScore,
            moneyScore: local.moneyScore,
            fortuneText: themedMessage,
            luckyAction: luckyAction,
            oneLiner: "今日の守護猫は\(card.name)にゃ"
        )

        return CatCardResult(
            deckIndex: deckIndex,
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
