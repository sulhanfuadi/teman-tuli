import Foundation

protocol APIClient {
    func register(name: String, email: String, password: String, goal: String?) async throws -> (AuthUser, String)
    func login(email: String, password: String) async throws -> (AuthUser, String)
    func fetchSessions(token: String) async throws -> [TranscriptSession]
    func createSession(token: String, payload: NewTranscriptSession) async throws -> TranscriptSession
    func fetchSession(token: String, id: String) async throws -> TranscriptSession
    func updateSession(token: String, id: String, title: String?, className: String?, notes: String?) async throws -> TranscriptSession
    func deleteSession(token: String, id: String) async throws
    func submitFeedback(token: String, sessionId: String, rating: CaptionFeedbackRating, comment: String?) async throws
}

enum APIError: Error, Equatable {
    case invalidURL
    case unauthorized
    case networkUnavailable
    case serverError(statusCode: Int)
    case decodingError
}

final class LiveAPIClient: APIClient {
    private let baseURL: URL
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(baseURL: URL = URL(string: "http://localhost:3000/api/v1")!) {
        self.baseURL = baseURL
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
    }

    func register(name: String, email: String, password: String, goal: String?) async throws -> (AuthUser, String) {
        struct Payload: Codable { let name: String; let email: String; let password: String; let goal: String? }
        struct Response: Codable { let user: AuthUser; let token: String }
        let response: Response = try await request(path: "auth/register", method: "POST", body: Payload(name: name, email: email, password: password, goal: goal), token: nil)
        return (response.user, response.token)
    }

    func login(email: String, password: String) async throws -> (AuthUser, String) {
        struct Payload: Codable { let email: String; let password: String }
        struct Response: Codable { let user: AuthUser; let token: String }
        let response: Response = try await request(path: "auth/login", method: "POST", body: Payload(email: email, password: password), token: nil)
        return (response.user, response.token)
    }

    func fetchSessions(token: String) async throws -> [TranscriptSession] {
        try await request(path: "sessions", method: "GET", body: Optional<Int>.none, token: token)
    }

    func createSession(token: String, payload: NewTranscriptSession) async throws -> TranscriptSession {
        try await request(path: "sessions", method: "POST", body: payload, token: token)
    }

    func fetchSession(token: String, id: String) async throws -> TranscriptSession {
        try await request(path: "sessions/\(id)", method: "GET", body: Optional<Int>.none, token: token)
    }

    func updateSession(token: String, id: String, title: String?, className: String?, notes: String?) async throws -> TranscriptSession {
        struct Payload: Codable { let title: String?; let className: String?; let notes: String? }
        return try await request(path: "sessions/\(id)", method: "PATCH", body: Payload(title: title, className: className, notes: notes), token: token)
    }

    func deleteSession(token: String, id: String) async throws {
        let _: EmptyResponse = try await request(path: "sessions/\(id)", method: "DELETE", body: Optional<Int>.none, token: token)
    }

    func submitFeedback(token: String, sessionId: String, rating: CaptionFeedbackRating, comment: String?) async throws {
        struct Payload: Codable { let rating: CaptionFeedbackRating; let comment: String? }
        let _: EmptyResponse = try await request(path: "sessions/\(sessionId)/feedback", method: "POST", body: Payload(rating: rating, comment: comment), token: token)
    }

    private func request<T: Decodable, B: Encodable>(path: String, method: String, body: B?, token: String?) async throws -> T {
        guard let url = URL(string: path, relativeTo: baseURL) else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        if let body { request.httpBody = try encoder.encode(body) }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw APIError.networkUnavailable
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(statusCode: -1)
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw APIError.unauthorized
        default:
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }

        if T.self == EmptyResponse.self { return EmptyResponse() as! T }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
}

private struct EmptyResponse: Codable {}
