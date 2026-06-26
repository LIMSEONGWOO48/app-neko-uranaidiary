import SwiftUI
import SwiftData

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Query private var profiles: [UserProfile]

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            } else if profiles.isEmpty {
                ProfileRegistrationView {
                    // SwiftData の @Query が更新されてホームへ遷移する
                }
            } else {
                HomeHubView()
            }
        }
        .animation(.easeInOut, value: hasCompletedOnboarding)
        .animation(.easeInOut, value: profiles.count)
    }
}

#Preview {
    RootView()
        .modelContainer(for: [UserProfile.self, DailyLog.self], inMemory: true)
}
