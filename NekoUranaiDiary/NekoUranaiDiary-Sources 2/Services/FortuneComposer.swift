import Foundation

struct LocalFortuneBase {
    let totalScore: Int
    let loveScore: Int
    let workScore: Int
    let moneyScore: Int
    let luckyAction: String
    let fallbackFortuneText: String
    let fallbackOneLiner: String
}

enum FortuneComposer {
    static func compose(
        local: LocalFortuneBase,
        aiText: FortuneAIText?
    ) -> FortuneResult {
        FortuneResult(
            totalScore: local.totalScore,
            loveScore: local.loveScore,
            workScore: local.workScore,
            moneyScore: local.moneyScore,
            fortuneText: aiText?.fortuneText ?? local.fallbackFortuneText,
            luckyAction: local.luckyAction,
            oneLiner: aiText?.oneLiner ?? local.fallbackOneLiner
        )
    }

    static func generate(
        profile: UserProfile,
        mood: Mood,
        category: ConcernCategory,
        memo: String?
    ) async -> FortuneResult {
        let local = FortuneGenerator.generateLocal(
            mood: mood,
            category: category,
            memo: memo,
            birthday: profile.birthday
        )

        guard AIConfig.isBackendConfigured else {
            return compose(local: local, aiText: nil)
        }

        let request = FortuneAIRequest(
            nickname: profile.nickname,
            mood: mood.rawValue,
            category: category.rawValue,
            memo: memo,
            totalScore: local.totalScore,
            loveScore: local.loveScore,
            workScore: local.workScore,
            moneyScore: local.moneyScore,
            luckyAction: local.luckyAction
        )

        do {
            let aiText = try await AIService.shared.generateFortuneText(request)
            return compose(local: local, aiText: aiText)
        } catch {
            return compose(local: local, aiText: nil)
        }
    }
}
