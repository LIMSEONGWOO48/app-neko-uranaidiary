import Foundation

enum Mood: String, CaseIterable, Codable, Identifiable {
    case veryGood = "とても良い"
    case good = "良い"
    case normal = "普通"
    case tired = "疲れた"
    case anxious = "不安"
    case irritated = "イライラ"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .veryGood: "😸"
        case .good: "😺"
        case .normal: "🐱"
        case .tired: "😿"
        case .anxious: "😰"
        case .irritated: "😾"
        }
    }

    /// 気分用イラストアセット名（未設定の気分は絵文字表示）
    var imageAssetName: String? {
        switch self {
        case .veryGood: "MoodVeryGood"
        case .good: "MoodGood"
        case .normal: "MoodNormal"
        case .tired: "MoodTired"
        case .anxious: "MoodAnxious"
        case .irritated: "MoodIrritated"
        }
    }
}
