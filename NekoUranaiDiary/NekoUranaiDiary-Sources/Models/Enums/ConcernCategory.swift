import Foundation

enum ConcernCategory: String, CaseIterable, Codable, Identifiable {
    case love = "恋愛"
    case work = "仕事"
    case money = "お金"
    case relationships = "人間関係"
    case selfGrowth = "自己成長"
    case other = "その他"

    var id: String { rawValue }
}
