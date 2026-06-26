import Foundation

enum LogFilter {
    static let freePlanVisibleDays = 7

    static func visibleLogs(
        from logs: [DailyLog],
        userId: String,
        planType: PlanType
    ) -> [DailyLog] {
        let userLogs = logs
            .filter { $0.userId == userId }
            .sorted { $0.date > $1.date }

        guard planType == .free else { return userLogs }

        let startOfToday = Calendar.current.startOfDay(for: .now)
        guard let cutoff = Calendar.current.date(
            byAdding: .day,
            value: -(freePlanVisibleDays - 1),
            to: startOfToday
        ) else {
            return userLogs
        }

        return userLogs.filter { $0.date >= cutoff }
    }

    static func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    static func startOfToday() -> Date {
        Calendar.current.startOfDay(for: .now)
    }
}
