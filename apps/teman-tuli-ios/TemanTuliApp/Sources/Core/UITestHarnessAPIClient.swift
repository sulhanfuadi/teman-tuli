import Foundation

@MainActor
final class UITestHarnessAPIClient: APIClient {
    private var sessions: [TranscriptSession] = []

    func register(name: String, email: String, password: String, goal: String?) async throws -> (AuthUser, String) {
        let user = AuthUser(id: UUID().uuidString, name: name, email: email, goal: goal)
        return (user, "uitest-token")
    }

    func login(email: String, password: String) async throws -> (AuthUser, String) {
        let user = AuthUser(id: "uitest-user", name: "UITest User", email: email, goal: nil)
        return (user, "uitest-token")
    }

    func fetchSessions(token: String) async throws -> [TranscriptSession] {
        sessions
    }

    func createSession(token: String, payload: NewTranscriptSession) async throws -> TranscriptSession {
        let created = TranscriptSession(
            id: UUID().uuidString,
            title: payload.title,
            className: payload.className,
            languageCode: payload.languageCode,
            fullText: payload.fullText,
            notes: payload.notes,
            startedAt: payload.startedAt,
            endedAt: payload.endedAt,
            createdAt: Date(),
            updatedAt: Date(),
            segments: payload.segments
        )
        sessions.append(created)
        return created
    }

    func fetchSession(token: String, id: String) async throws -> TranscriptSession {
        guard let session = sessions.first(where: { $0.id == id }) else {
            throw APIError.serverError(statusCode: 404, code: "NOT_FOUND", message: "Session not found", requestId: "uitest-0001")
        }
        return session
    }

    func updateSession(token: String, id: String, title: String?, className: String?, notes: String?) async throws -> TranscriptSession {
        guard let index = sessions.firstIndex(where: { $0.id == id }) else {
            throw APIError.serverError(statusCode: 404, code: "NOT_FOUND", message: "Session not found", requestId: "uitest-0002")
        }

        var session = sessions[index]
        if let title { session.title = title }
        session.className = className
        session.notes = notes
        session.updatedAt = Date()
        sessions[index] = session
        return session
    }

    func deleteSession(token: String, id: String) async throws {
        guard sessions.contains(where: { $0.id == id }) else {
            throw APIError.serverError(statusCode: 404, code: "NOT_FOUND", message: "Session not found", requestId: "uitest-0003")
        }
        sessions.removeAll { $0.id == id }
    }

    func submitFeedback(token: String, sessionId: String, rating: CaptionFeedbackRating, comment: String?) async throws {
        guard sessions.contains(where: { $0.id == sessionId }) else {
            throw APIError.serverError(statusCode: 404, code: "NOT_FOUND", message: "Session not found", requestId: "uitest-0004")
        }
    }
}
