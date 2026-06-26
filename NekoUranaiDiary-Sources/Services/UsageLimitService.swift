import Foundation
import SwiftData

enum PlanLimits {
    static let freeChatTotal = 3
    static let premiumChatMonthly = 30
    static let ticketChatAmount = 10
    static let freeFortuneDaily = 1
    static let premiumFortuneDaily = 3
}

struct UsageStatus {
    let remainingChats: Int
    let remainingFortunes: Int
    let canChat: Bool
    let canFortune: Bool
    let chatLimitMessage: String
    let fortuneLimitMessage: String
}

enum UsageLimitService {
    static func resolve(
        context: ModelContext,
        userId: String
    ) -> UsageLimit {
        let descriptor = FetchDescriptor<UsageLimit>(
            predicate: #Predicate<UsageLimit> { $0.userId == userId }
        )

        if let existing = try? context.fetch(descriptor).first {
            refreshPeriodIfNeeded(existing)
            return existing
        }

        let usage = UsageLimit(userId: userId)
        context.insert(usage)
        try? context.save()
        return usage
    }

    static func status(
        profile: UserProfile,
        usage: UsageLimit
    ) -> UsageStatus {
        let remainingChats = remainingChatCount(profile: profile, usage: usage)
        let remainingFortunes = remainingFortuneCount(profile: profile, usage: usage)

        return UsageStatus(
            remainingChats: remainingChats,
            remainingFortunes: remainingFortunes,
            canChat: remainingChats > 0,
            canFortune: remainingFortunes > 0,
            chatLimitMessage: chatLimitMessage(profile: profile, usage: usage),
            fortuneLimitMessage: fortuneLimitMessage(profile: profile, usage: usage)
        )
    }

    static func remainingChatCount(
        profile: UserProfile,
        usage: UsageLimit
    ) -> Int {
        switch profile.planTypeEnum {
        case .premium:
            let monthly = max(0, PlanLimits.premiumChatMonthly - usage.premiumChatUsed)
            return monthly + usage.ticketBalance
        case .free:
            let trial = max(0, PlanLimits.freeChatTotal - usage.freeTrialUsed)
            return trial + usage.ticketBalance
        }
    }

    static func remainingFortuneCount(
        profile: UserProfile,
        usage: UsageLimit
    ) -> Int {
        let limit = fortuneDailyLimit(for: profile.planTypeEnum)
        return max(0, limit - usage.fortuneUsedCount)
    }

    static func fortuneDailyLimit(for plan: PlanType) -> Int {
        switch plan {
        case .free: PlanLimits.freeFortuneDaily
        case .premium: PlanLimits.premiumFortuneDaily
        }
    }

    @discardableResult
    static func consumeChat(
        profile: UserProfile,
        usage: UsageLimit
    ) -> Bool {
        refreshPeriodIfNeeded(usage)

        switch profile.planTypeEnum {
        case .premium:
            if usage.premiumChatUsed < PlanLimits.premiumChatMonthly {
                usage.premiumChatUsed += 1
                return true
            }
            if usage.ticketBalance > 0 {
                usage.ticketBalance -= 1
                return true
            }
        case .free:
            if usage.freeTrialUsed < PlanLimits.freeChatTotal {
                usage.freeTrialUsed += 1
                return true
            }
            if usage.ticketBalance > 0 {
                usage.ticketBalance -= 1
                return true
            }
        }

        return false
    }

    @discardableResult
    static func consumeFortune(
        profile: UserProfile,
        usage: UsageLimit
    ) -> Bool {
        refreshPeriodIfNeeded(usage)

        let limit = fortuneDailyLimit(for: profile.planTypeEnum)
        guard usage.fortuneUsedCount < limit else { return false }

        usage.fortuneUsedCount += 1
        return true
    }

    static func grantTickets(
        usage: UsageLimit,
        count: Int = PlanLimits.ticketChatAmount
    ) {
        usage.ticketBalance += count
    }

    private static func refreshPeriodIfNeeded(_ usage: UsageLimit) {
        let currentMonth = UsageLimit.currentMonthKey()
        if usage.month != currentMonth {
            usage.month = currentMonth
            usage.premiumChatUsed = 0
        }

        let today = UsageLimit.currentDayKey()
        if usage.fortuneDay != today {
            usage.fortuneDay = today
            usage.fortuneUsedCount = 0
        }
    }

    private static func chatLimitMessage(
        profile: UserProfile,
        usage: UsageLimit
    ) -> String {
        let remaining = remainingChatCount(profile: profile, usage: usage)
        guard remaining == 0 else {
            return "残り \(remaining) 回相談できます"
        }

        switch profile.planTypeEnum {
        case .free:
            return "無料相談は\(PlanLimits.freeChatTotal)回までです。プレミアムまたはチケットで追加できます"
        case .premium:
            return "今月の相談回数を使い切りました。チケットで追加できます"
        }
    }

    private static func fortuneLimitMessage(
        profile: UserProfile,
        usage: UsageLimit
    ) -> String {
        let remaining = remainingFortuneCount(profile: profile, usage: usage)
        let limit = fortuneDailyLimit(for: profile.planTypeEnum)

        guard remaining == 0 else {
            return "今日あと \(remaining) 回占えます"
        }

        return "今日の占い回数（\(limit)回）を使い切りました"
    }
}
