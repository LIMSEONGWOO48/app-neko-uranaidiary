import Foundation

enum AIConfig {
    /// Xcode の Info または Scheme 環境変数 `AI_BACKEND_BASE_URL` で設定
    /// 例: http://127.0.0.1:5001/nekouranai-diary/asia-northeast1/api
    static var backendBaseURL: URL? {
        if let env = ProcessInfo.processInfo.environment["AI_BACKEND_BASE_URL"],
           !env.isEmpty,
           let url = URL(string: env) {
            return url
        }

        if let plist = Bundle.main.object(forInfoDictionaryKey: "AI_BACKEND_BASE_URL") as? String,
           !plist.isEmpty,
           let url = URL(string: plist) {
            return url
        }

        return nil
    }

    static var isBackendConfigured: Bool {
        backendBaseURL != nil
    }
}
