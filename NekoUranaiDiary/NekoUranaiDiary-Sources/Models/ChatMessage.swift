import Foundation
import SwiftData

enum ChatRole: String, Codable {
    case user
    case assistant
}

@Model
final class ChatMessage {
    var userId: String
    var role: String
    var message: String
    var createdAt: Date

    init(
        userId: String,
        role: ChatRole,
        message: String,
        createdAt: Date = .now
    ) {
        self.userId = userId
        self.role = role.rawValue
        self.message = message
        self.createdAt = createdAt
    }

    var roleEnum: ChatRole {
        ChatRole(rawValue: role) ?? .user
    }

    var isFromUser: Bool {
        roleEnum == .user
    }
}
