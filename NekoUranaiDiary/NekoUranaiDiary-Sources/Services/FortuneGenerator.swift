import Foundation

enum FortuneGenerator {
    private static let luckyActions: [ConcernCategory: [String]] = [
        .love: [
            "大切な人に感謝のひとことを伝える",
            "好きな香りのハンドクリームを塗る",
            "昔の楽しい写真を見返す"
        ],
        .work: [
            "今日のタスクを3つだけ書き出す",
            "15分だけ席を離れて深呼吸する",
            "終わった仕事をひとつだけ達成リストに入れる"
        ],
        .money: [
            "今週の支出をざっくり確認する",
            "欲しいものリストを見直す",
            "財布の中を整理する"
        ],
        .relationships: [
            "久しぶりの友人にスタンプを送る",
            "感謝を感じた人の名前を紙に書く",
            "今日は相手の話を最後まで聞く"
        ],
        .selfGrowth: [
            "5分だけ読書や学習をする",
            "最近うまくいったことをひとつ書く",
            "新しいルートで散歩する"
        ],
        .other: [
            "お気に入りの飲み物をゆっくり味わう",
            "好きな音楽を1曲聴く",
            "窓を開けて外の空気を吸う"
        ]
    ]

    private static let oneLiners: [Mood: [String]] = [
        .veryGood: ["最高の一日になりそうにゃ！", "キラキラした運気が来てるにゃ！"],
        .good: ["穏やかに過ごせる一日にゃ。", "小さな幸せが見つかりそうにゃ。"],
        .normal: ["焦らなくて大丈夫にゃ。", "自分のペースでいこうにゃ。"],
        .tired: ["休むのも大事な仕事にゃ。", "無理せず、ゆっくりいこうにゃ。"],
        .anxious: ["不安は未来へのサインにゃ。", "ひとつずつ整理していこうにゃ。"],
        .irritated: ["感情を認めてあげてにゃ。", "深呼吸で少しずつ落ち着くにゃ。"]
    ]

    private static let fortuneTexts: [Mood: [String]] = [
        .veryGood: [
            "今日は心が軽く動きやすい日にゃ。新しいことにチャレンジすると、思いがけない良い流れが来るかもにゃ。",
            "周りへの感謝を伝えると、あなたの魅力がもっと伝わるにゃ。素直な気持ちがラッキーの鍵にゃ。"
        ],
        .good: [
            "今日はゆっくり自分のペースを大切にするにゃ。小さな幸せに気づける一日になりそうだにゃ。",
            "穏やかな気持ちで過ごすほど、良い出会いやひらめきが近づいてくるにゃ。"
        ],
        .normal: [
            "特別なことがなくても大丈夫にゃ。日常の中にある安心感を大切にしてみてにゃ。",
            "今日は地味にコツコツ進める日にゃ。小さな積み重ねが後から大きな力になるにゃ。"
        ],
        .tired: [
            "疲れているときこそ、自分をいたわるチャンスにゃ。今夜は早めに休むのが一番の開運行動にゃ。",
            "頑張りすぎないでにゃ。今日できることをひとつだけ決めて、それだけで十分にゃ。"
        ],
        .anxious: [
            "不安な気持ちは、大切にしたい気持ちの裏返しにゃ。全部を今日決めなくても大丈夫にゃ。",
            "心がざわつく日は、情報を少し減らすのが吉にゃ。静かな時間を意識的に作ってみてにゃ。"
        ],
        .irritated: [
            "イライラはエネルギーのサインにゃ。体を動かすか、好きなことで気分を切り替えてみるにゃ。",
            "今日は結論を急がないでにゃ。一度距離を置くと、本当に大切なことが見えてくるにゃ。"
        ]
    ]

    static func generateLocal(
        mood: Mood,
        category: ConcernCategory,
        memo: String?,
        birthday: Date
    ) -> LocalFortuneBase {
        let seed = dailySeed(birthday: birthday, mood: mood, category: category)
        var generator = SeededRandomNumberGenerator(seed: seed)

        let baseScore = baseScore(for: mood)
        let totalScore = clamp(baseScore + Int.random(in: -1...1, using: &generator))
        let loveScore = clamp(adjustedScore(base: baseScore, category: category, target: .love, generator: &generator))
        let workScore = clamp(adjustedScore(base: baseScore, category: category, target: .work, generator: &generator))
        let moneyScore = clamp(adjustedScore(base: baseScore, category: category, target: .money, generator: &generator))

        let actions = luckyActions[category] ?? luckyActions[.other]!
        let luckyAction = actions.randomElement(using: &generator) ?? actions[0]

        let liners = oneLiners[mood] ?? oneLiners[.normal]!
        let oneLiner = liners.randomElement(using: &generator) ?? liners[0]

        var texts = fortuneTexts[mood] ?? fortuneTexts[.normal]!
        if let memo, !memo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            texts.append("「\(memo)」という気持ち、ちゃんと届いているにゃ。自分の感覚を大切にしてにゃ。")
        }
        let fortuneText = texts.randomElement(using: &generator) ?? texts[0]

        return LocalFortuneBase(
            totalScore: totalScore,
            loveScore: loveScore,
            workScore: workScore,
            moneyScore: moneyScore,
            luckyAction: luckyAction,
            fallbackFortuneText: fortuneText,
            fallbackOneLiner: oneLiner
        )
    }

    /// オフライン・フォールバック用
    static func generate(
        mood: Mood,
        category: ConcernCategory,
        memo: String?,
        birthday: Date
    ) -> FortuneResult {
        let local = generateLocal(
            mood: mood,
            category: category,
            memo: memo,
            birthday: birthday
        )
        return FortuneComposer.compose(local: local, aiText: nil)
    }

    private static func dailySeed(birthday: Date, mood: Mood, category: ConcernCategory) -> UInt64 {
        let day = UInt64(Calendar.current.startOfDay(for: .now).timeIntervalSince1970)
        let birthDay = UInt64(Calendar.current.startOfDay(for: birthday).timeIntervalSince1970)
        let moodHash = stableHash(mood.rawValue)
        let categoryHash = stableHash(category.rawValue)
        return day ^ birthDay ^ moodHash ^ categoryHash
    }

    private static func stableHash(_ value: String) -> UInt64 {
        var hash: UInt64 = 5381
        for byte in value.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(byte)
        }
        return hash
    }

    private static func baseScore(for mood: Mood) -> Int {
        switch mood {
        case .veryGood: 5
        case .good: 4
        case .normal: 3
        case .tired: 2
        case .anxious: 2
        case .irritated: 2
        }
    }

    private enum ScoreTarget {
        case love, work, money
    }

    private static func adjustedScore(
        base: Int,
        category: ConcernCategory,
        target: ScoreTarget,
        generator: inout SeededRandomNumberGenerator
    ) -> Int {
        let bonus: Int
        switch (category, target) {
        case (.love, .love), (.work, .work), (.money, .money):
            bonus = 1
        case (.relationships, .love):
            bonus = 1
        case (.selfGrowth, .work):
            bonus = 1
        default:
            bonus = 0
        }
        return base + bonus + Int.random(in: -1...1, using: &generator)
    }

    private static func clamp(_ value: Int) -> Int {
        min(5, max(1, value))
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
