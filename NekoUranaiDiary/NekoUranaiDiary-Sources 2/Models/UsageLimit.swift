import Foundation
import SwiftData

@Model
final class UsageLimit {
    var userId: String
    var month: String
    var fortuneDay: String
    var freeTrialUsed: Int
    var premiumChatUsed: Int
    var fortuneUsedCount: Int
    var ticketBalance: Int

    init(
        userId: String,
        month: String = UsageLimit.currentMonthKey(),
        fortuneDay: String = UsageLimit.currentDayKey(),
        freeTrialUsed: Int = 0,
        premiumChatUsed: Int = 0,
        fortuneUsedCount: Int = 0,
        ticketBalance: Int = 0
    ) {
        self.userId = userId
        self.month = month
        self.fortuneDay = fortuneDay
        self.freeTrialUsed = freeTrialUsed
        self.premiumChatUsed = premiumChatUsed
        self.fortuneUsedCount = fortuneUsedCount
        self.ticketBalance = ticketBalance
    }

    static func currentMonthKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: .now)
    }

    static func currentDayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: .now)
    }
}
