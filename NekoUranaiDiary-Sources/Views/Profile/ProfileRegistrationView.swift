import SwiftUI
import SwiftData

struct ProfileRegistrationView: View {
    let onComplete: () -> Void

    @Environment(\.modelContext) private var modelContext

    @State private var nickname = ""
    @State private var birthday = Calendar.current.date(
        byAdding: .year,
        value: -25,
        to: .now
    ) ?? .now
    @State private var selectedGender: Gender?
    @State private var selectedCategory: ConcernCategory = .love

    private var isValid: Bool {
        !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("プロフィール登録")
                    .font(.title.bold())

                Text("あなたに合った占いと相談のために、\n少しだけ教えてにゃ。")
                    .foregroundStyle(AppTheme.secondaryText)

                VStack(alignment: .leading, spacing: 8) {
                    Text("ニックネーム")
                        .font(.subheadline.bold())
                    TextField("例：みけちゃん", text: $nickname)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("生年月日")
                        .font(.subheadline.bold())
                    DatePicker(
                        "生年月日",
                        selection: $birthday,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("性別（任意）")
                        .font(.subheadline.bold())
                    Picker("性別", selection: $selectedGender) {
                        Text("未選択").tag(Gender?.none)
                        ForEach(Gender.allCases) { gender in
                            Text(gender.rawValue).tag(Gender?.some(gender))
                        }
                    }
                    .pickerStyle(.menu)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("よく相談するジャンル")
                        .font(.subheadline.bold())
                    Picker("相談ジャンル", selection: $selectedCategory) {
                        ForEach(ConcernCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }

                PrimaryButton(title: "登録してはじめる") {
                    saveProfile()
                }
                .disabled(!isValid)
                .opacity(isValid ? 1 : 0.5)
            }
            .padding(24)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }

    private func saveProfile() {
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedNickname.isEmpty else { return }

        let profile = UserProfile(
            nickname: trimmedNickname,
            birthday: birthday,
            gender: selectedGender?.rawValue,
            concernCategory: selectedCategory
        )
        modelContext.insert(profile)
        try? modelContext.save()
        onComplete()
    }
}

#Preview {
    ProfileRegistrationView(onComplete: {})
        .modelContainer(for: [UserProfile.self], inMemory: true)
}
