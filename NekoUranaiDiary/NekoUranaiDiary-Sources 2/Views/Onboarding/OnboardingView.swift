import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            AppTheme.screenBackground

            VStack(spacing: 28) {
                Spacer()

                MeowAvatarView(size: 140)

                VStack(spacing: 10) {
                    Text(MeowCharacter.title)
                        .font(.largeTitle.bold())
                        .foregroundStyle(AppTheme.accentDark)

                    Text("あなた専属のAI猫占い師")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)

                    Text("「\(MeowCharacter.catchphrase)」")
                        .font(.headline)
                        .foregroundStyle(AppTheme.accent)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }

                MeowSpeechBubble(text: "今日の気分や悩みに合わせて、\n毎日の運勢やアドバイスを届けるにゃ。")

                Spacer()

                PrimaryButton(title: "はじめる") {
                    onComplete()
                }
            }
            .padding(24)
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
