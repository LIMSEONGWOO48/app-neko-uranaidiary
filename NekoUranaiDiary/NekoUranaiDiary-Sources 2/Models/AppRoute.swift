import Foundation

enum AppRoute: Hashable {
    case moodFortune
    case catCard
    case fortune(FortuneResult)
    case chat
    case logs
    case paywall
}
