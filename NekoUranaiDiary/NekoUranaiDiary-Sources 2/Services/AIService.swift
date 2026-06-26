import Foundation

struct FortuneAIRequest: Codable {
    let nickname: String?
    let mood: String
    let category: String
    let memo: String?
    let totalScore: Int
    let loveScore: Int
    let workScore: Int
    let moneyScore: Int
    let luckyAction: String
}

struct FortuneAIText: Codable {
    let fortuneText: String
    let oneLiner: String
}

struct ChatHistoryItem: Codable {
    let role: String
    let message: String
}

struct ChatAIRequest: Codable {
    let nickname: String?
    let concernCategory: String?
    let message: String
    let history: [ChatHistoryItem]
}

struct ChatAIResponse: Codable {
    let reply: String
}

enum AIServiceError: LocalizedError {
    case backendNotConfigured
    case invalidResponse
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .backendNotConfigured:
            "AIバックエンドが設定されていません"
        case .invalidResponse:
            "AIからの応答を読み取れませんでした"
        case .serverError(let code):
            "サーバーエラー (\(code))"
        }
    }
}

protocol AIServiceProtocol {
    func generateFortuneText(_ request: FortuneAIRequest) async throws -> FortuneAIText
    func chatConsult(_ request: ChatAIRequest) async throws -> String
}

final class CloudAIService: AIServiceProtocol {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func generateFortuneText(_ request: FortuneAIRequest) async throws -> FortuneAIText {
        try await post(path: "generateFortune", body: request)
    }

    func chatConsult(_ request: ChatAIRequest) async throws -> String {
        let response: ChatAIResponse = try await post(path: "chatConsult", body: request)
        return response.reply
    }

    private func post<T: Decodable, B: Encodable>(
        path: String,
        body: B
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw AIServiceError.serverError(http.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

enum AIService {
    static let shared: AIServiceProtocol = {
        if let baseURL = AIConfig.backendBaseURL {
            return CloudAIService(baseURL: baseURL)
        }
        return UnavailableAIService()
    }()
}

private struct UnavailableAIService: AIServiceProtocol {
    func generateFortuneText(_ request: FortuneAIRequest) async throws -> FortuneAIText {
        throw AIServiceError.backendNotConfigured
    }

    func chatConsult(_ request: ChatAIRequest) async throws -> String {
        throw AIServiceError.backendNotConfigured
    }
}
