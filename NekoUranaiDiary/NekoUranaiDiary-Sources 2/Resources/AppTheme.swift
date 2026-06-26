import SwiftUI

enum MeowCharacter {
    static let name = "ミャオ"
    static let title = "猫占い師 \(name)"
    static let catchphrase = "大丈夫にゃ、きっとうまくいくにゃ"
    static let greeting = "今日も一緒にがんばろうにゃ！"
}

enum AppTheme {
  // ミャオのマント・帽子（ラベンダーパープル）
  static let accent = Color(red: 0.545, green: 0.424, blue: 0.671)
  static let accentDark = Color(red: 0.42, green: 0.30, blue: 0.55)
  static let accentLight = Color(red: 0.78, green: 0.70, blue: 0.90)

  // 星・トリム（ゴールド）
  static let gold = Color(red: 0.91, green: 0.77, blue: 0.41)

  // 背景（占い部屋の柔らかいクリーム×ラベンダー）
  static let background = Color(red: 0.96, green: 0.94, blue: 0.99)
  static let backgroundGradientTop = Color(red: 0.94, green: 0.90, blue: 0.98)
  static let backgroundGradientBottom = Color(red: 0.99, green: 0.97, blue: 0.95)

  static let cardBackground = Color.white.opacity(0.92)
  static let cardBorder = accentLight.opacity(0.55)

  // 吹き出し（ピンク系）
  static let assistantBubble = Color(red: 0.98, green: 0.93, blue: 0.97)
  static let userBubble = accent

  static let secondaryText = Color(red: 0.45, green: 0.38, blue: 0.52)
  static let tertiaryText = Color.secondary

  static var screenBackground: some View {
    LinearGradient(
      colors: [backgroundGradientTop, backgroundGradientBottom],
      startPoint: .top,
      endPoint: .bottom
    )
    .ignoresSafeArea()
  }

  static var accentGradient: LinearGradient {
    LinearGradient(
      colors: [accent, accentDark],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  static var cardGradient: LinearGradient {
    LinearGradient(
      colors: [accentLight.opacity(0.9), accent.opacity(0.75)],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }
}

struct MeowAvatarView: View {
  var size: CGFloat = 88
  var showGlow: Bool = true

  var body: some View {
    Image("MeowAvatar")
      .resizable()
      .scaledToFill()
      .frame(width: size, height: size)
      .clipShape(Circle())
      .overlay {
        Circle()
          .strokeBorder(AppTheme.gold.opacity(0.85), lineWidth: max(2, size * 0.035))
      }
      .shadow(color: AppTheme.accent.opacity(showGlow ? 0.35 : 0), radius: 12, y: 4)
  }
}

struct CatCard<Content: View>: View {
  let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    content
      .padding()
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(AppTheme.cardBackground)
      .clipShape(RoundedRectangle(cornerRadius: 18))
      .overlay {
        RoundedRectangle(cornerRadius: 18)
          .strokeBorder(AppTheme.cardBorder, lineWidth: 1)
      }
      .shadow(color: AppTheme.accent.opacity(0.10), radius: 10, y: 4)
  }
}

struct PrimaryButton: View {
  let title: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.headline)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppTheme.accentGradient)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: AppTheme.accent.opacity(0.28), radius: 8, y: 4)
    }
  }
}

struct ScoreStarsView: View {
  let score: Int
  let maxScore: Int = 5

  var body: some View {
    HStack(spacing: 4) {
      ForEach(1...maxScore, id: \.self) { index in
        Image(systemName: index <= score ? "star.fill" : "star")
          .foregroundStyle(index <= score ? AppTheme.gold : .gray.opacity(0.25))
      }
    }
  }
}

struct MeowSpeechBubble: View {
  let text: String

  var body: some View {
    HStack(alignment: .top, spacing: 10) {
      MeowAvatarView(size: 44, showGlow: false)

      Text(text)
        .font(.subheadline)
        .foregroundStyle(AppTheme.secondaryText)
        .padding(12)
        .background(AppTheme.assistantBubble)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
          RoundedRectangle(cornerRadius: 16)
            .strokeBorder(AppTheme.accentLight.opacity(0.5), lineWidth: 1)
        }
    }
  }
}
