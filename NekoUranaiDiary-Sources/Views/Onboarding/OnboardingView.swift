import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("🐱")
                .font(.system(size: 80))

            VStack(spacing: 12) {
                Text("猫占い日記")
                    .font(.largeTitle.bold())

                Text("あなた専属のAI猫占い師を作ります。")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.secondaryText)

                Text("今日の気分や悩みに合わせて、\n毎日の運勢やアドバイスを届けます。")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer()

            PrimaryButton(title: "はじめる") {
                onComplete()
            }
        }
        .padding(24)
        .background(AppTheme.background.ignoresSafeArea())
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
