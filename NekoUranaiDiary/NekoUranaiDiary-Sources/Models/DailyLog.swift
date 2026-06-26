import Foundation
import SwiftData

@Model
final class DailyLog {
    var userId: String
    var date: Date
    var mood: String
    var concernCategory: String
    var memo: String?
    var fortuneText: String
    var totalScore: Int
    var loveScore: Int
    var workScore: Int
    var moneyScore: Int
    var luckyAction: String
    var createdAt: Date

    init(
        userId: String,
        date: Date,
        mood: Mood,
        concernCategory: ConcernCategory,
        memo: String? = nil,
        fortuneText: String,
        totalScore: Int,
        loveScore: Int,
        workScore: Int,
        moneyScore: Int,
        luckyAction: String,
        createdAt: Date = .now
    ) {
        self.userId = userId
        self.date = date
        self.mood = mood.rawValue
        self.concernCategory = concernCategory.rawValue
        self.memo = memo
        self.fortuneText = fortuneText
        self.totalScore = totalScore
        self.loveScore = loveScore
        self.workScore = workScore
        self.moneyScore = moneyScore
        self.luckyAction = luckyAction
        self.createdAt = createdAt
    }

    var moodEnum: Mood {
        Mood(rawValue: mood) ?? .normal
    }

    var concernCategoryEnum: ConcernCategory {
        ConcernCategory(rawValue: concernCategory) ?? .other
    }

    var asFortuneResult: FortuneResult {
        FortuneResult(
            totalScore: totalScore,
            loveScore: loveScore,
            workScore: workScore,
            moneyScore: moneyScore,
            fortuneText: fortuneText,
            luckyAction: luckyAction,
            oneLiner: String(fortuneText.prefix(30))
        )
    }
}
