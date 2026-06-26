import SwiftUI
import SwiftData

struct ChatConsultationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \ChatMessage.createdAt) private var allMessages: [ChatMessage]
    @Query private var allUsageLimits: [UsageLimit]

    @State private var inputText = ""
    @State private var inputFieldID = UUID()
    @FocusState private var isInputFocused: Bool
    @State private var isSending = false
    @State private var errorMessage: String?
    @State private var showPaywall = false

    private var profile: UserProfile? { profiles.first }

    private var usageLimit: UsageLimit? {
        guard let profile else { return nil }
        return allUsageLimits.first { $0.userId == profile.userId }
    }

    private var usageStatus: UsageStatus? {
        guard let profile, let usageLimit else { return nil }
        return UsageLimitService.status(profile: profile, usage: usageLimit)
    }

    private var userMessages: [ChatMessage] {
        guard let profile else { return [] }
        return allMessages.filter { $0.userId == profile.userId }
    }

    private var canSend: Bool {
        usageStatus?.canChat == true
            && !isSending
            && !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if let usageStatus {
                    Text("残り相談回数: \(usageStatus.remainingChats) 回")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                if AIConfig.isBackendConfigured {
                    Text("AI接続中")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.accent)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(AppTheme.cardBackground)

            if usageStatus?.canChat == false {
                limitBanner
            }

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if userMessages.isEmpty {
                            welcomeBubble
                        }

                        ForEach(userMessages) { message in
                            ChatBubbleView(message: message)
                                .id(message.persistentModelID)
                        }

                        if isSending {
                            HStack {
                                ProgressView()
                                    .padding(12)
                                    .background(AppTheme.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                Spacer(minLength: 40)
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: userMessages.count) { _, _ in
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: isSending) { _, _ in
                    scrollToBottom(proxy: proxy)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }

            HStack(spacing: 12) {
                TextField(
                    canSend || usageStatus?.canChat == true
                        ? "相談内容を入力..."
                        : "相談回数の上限に達しました",
                    text: $inputText,
                    axis: .vertical
                )
                .id(inputFieldID)
                .focused($isInputFocused)
                .lineLimit(1...4)
                .padding(12)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .disabled(isSending || usageStatus?.canChat == false)

                Button {
                    Task {
                        await sendMessage()
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(AppTheme.accent)
                        .clipShape(Circle())
                }
                .disabled(!canSend)
            }
            .padding()
            .background(AppTheme.backgroundGradientBottom)
        }
        .background(AppTheme.screenBackground)
        .navigationTitle("AI猫占い相談")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            ensureUsageLimit()
        }
        .navigationDestination(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private var limitBanner: some View {
        VStack(spacing: 8) {
            Text(usageStatus?.chatLimitMessage ?? "相談回数の上限に達しました")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)

            Button("プレミアム・チケットを見る") {
                showPaywall = true
            }
            .font(.caption.bold())
            .foregroundStyle(AppTheme.accent)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppTheme.accent.opacity(0.1))
    }

    private var welcomeBubble: some View {
        MeowSpeechBubble(text: "悩みを話してにゃ。\(MeowCharacter.name)が一緒に整理していこうにゃ 🐾")
    }

    private func ensureUsageLimit() {
        guard let profile else { return }
        _ = UsageLimitService.resolve(context: modelContext, userId: profile.userId)
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let last = userMessages.last else { return }
        withAnimation {
            proxy.scrollTo(last.persistentModelID, anchor: .bottom)
        }
    }

    private func sendMessage() async {
        guard let profile else { return }

        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSending else { return }

        let usage = UsageLimitService.resolve(context: modelContext, userId: profile.userId)
        let status = UsageLimitService.status(profile: profile, usage: usage)

        guard status.canChat else {
            errorMessage = status.chatLimitMessage
            return
        }

        guard UsageLimitService.consumeChat(profile: profile, usage: usage) else {
            errorMessage = status.chatLimitMessage
            return
        }
        try? modelContext.save()

        let messageToSend = trimmed
        clearInput()

        errorMessage = nil
        isSending = true
        defer { isSending = false }

        let history = userMessages
            .suffix(8)
            .map {
                ChatHistoryItem(role: $0.role, message: $0.message)
            }

        let userMessage = ChatMessage(
            userId: profile.userId,
            role: .user,
            message: messageToSend
        )
        modelContext.insert(userMessage)
        try? modelContext.save()

        let reply: String
        if AIConfig.isBackendConfigured {
            do {
                let request = ChatAIRequest(
                    nickname: profile.nickname,
                    concernCategory: profile.concernCategory,
                    message: messageToSend,
                    history: Array(history)
                )
                reply = try await AIService.shared.chatConsult(request)
            } catch {
                reply = fallbackReply()
                errorMessage = "AIに接続できなかったため、オフライン応答を表示しています"
            }
        } else {
            reply = fallbackReply()
        }

        let assistantMessage = ChatMessage(
            userId: profile.userId,
            role: .assistant,
            message: reply
        )
        modelContext.insert(assistantMessage)
        try? modelContext.save()
    }

    private func clearInput() {
        inputText = ""
        inputFieldID = UUID()
        isInputFocused = false
    }

    private func fallbackReply() -> String {
        "うんうん、それはつらかったにゃ。今日は自分を責めすぎないで、ゆっくり休むのがいいにゃ。"
    }
}

private struct ChatBubbleView: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromUser { Spacer(minLength: 40) }

            Text(message.message)
                .padding(12)
                .background(message.isFromUser ? AppTheme.userBubble : AppTheme.assistantBubble)
                .foregroundStyle(message.isFromUser ? .white : AppTheme.secondaryText)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)

            if !message.isFromUser { Spacer(minLength: 40) }
        }
    }
}

#Preview {
    NavigationStack {
        ChatConsultationView()
    }
    .modelContainer(for: [UserProfile.self, ChatMessage.self, UsageLimit.self], inMemory: true)
}
