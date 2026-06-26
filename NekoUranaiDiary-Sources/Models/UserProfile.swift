import Foundation
import SwiftData

@Model
final class UserProfile {
    var userId: String
    var nickname: String
    var birthday: Date
    var gender: String?
    var concernCategory: String
    var planType: String
    var createdAt: Date

    init(
        nickname: String,
        birthday: Date,
        gender: String? = nil,
        concernCategory: ConcernCategory,
        planType: PlanType = .free,
        userId: String = UUID().uuidString,
        createdAt: Date = .now
    ) {
        self.userId = userId
        self.nickname = nickname
        self.birthday = birthday
        self.gender = gender
        self.concernCategory = concernCategory.rawValue
        self.planType = planType.rawValue
        self.createdAt = createdAt
    }

    var concernCategoryEnum: ConcernCategory {
        ConcernCategory(rawValue: concernCategory) ?? .other
    }

    var planTypeEnum: PlanType {
        PlanType(rawValue: planType) ?? .free
    }
}
