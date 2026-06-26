import Foundation

enum PlanType: String, Codable {
    case free
    case premium

    var displayName: String {
        switch self {
        case .free: "無料"
        case .premium: "プレミアム"
        }
    }
}
