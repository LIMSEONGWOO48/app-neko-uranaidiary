import SwiftUI
import SwiftData

@main
struct NekoUranaiDiaryApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [
            UserProfile.self,
            DailyLog.self,
            ChatMessage.self,
            UsageLimit.self
        ])
    }
}
