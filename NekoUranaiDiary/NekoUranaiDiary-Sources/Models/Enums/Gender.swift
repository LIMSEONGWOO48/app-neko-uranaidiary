import Foundation

enum Gender: String, CaseIterable, Codable, Identifiable {
    case female = "女性"
    case male = "男性"
    case other = "その他"
    case preferNotToSay = "回答しない"

    var id: String { rawValue }
}
