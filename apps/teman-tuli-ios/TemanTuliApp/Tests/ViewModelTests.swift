import XCTest
@testable import TemanTuli

final class MockAPIClient: APIClient {
    var sessions: [TranscriptSession] = []

    func register(name: String, email: String, password: String, goal: String?) async throws -> (AuthUser, String) {
        (AuthUser(id: "u1", name: name, email: email, goal: goal), "token")
    }

    func fetchSessions(token: String) async throws -> [TranscriptSession] { sessions }

    func createSession(token: String, payload: NewTranscriptSession) async throws -> TranscriptSession {
        let session = TranscriptSession(
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
        sessions.append(session)
        return session
    }

    func fetchSession(token: String, id: String) async throws -> TranscriptSession {
        sessions.first { $0.id == id }!
    }

    func updateSession(token: String, id: String, title: String?, className: String?, notes: String?) async throws -> TranscriptSession {
        let index = sessions.firstIndex { $0.id == id }!
        sessions[index].notes = notes
        return sessions[index]
    }

    func deleteSession(token: String, id: String) async throws {}

    func submitFeedback(token: String, sessionId: String, rating: CaptionFeedbackRating, comment: String?) async throws {}
}

@MainActor
final class ViewModelTests: XCTestCase {
    func testSessionsLoadPrivateArchive() async {
        let api = MockAPIClient()
        api.sessions = [TranscriptSession(
            id: "s1",
            title: "Kuliah Aksesibilitas",
            className: "Design",
            languageCode: "id-ID",
            fullText: "Halo semua.",
            notes: nil,
            startedAt: Date(),
            endedAt: Date(),
            createdAt: Date(),
            updatedAt: Date(),
            segments: []
        )]
        let vm = SessionsViewModel(apiClient: api)
        await vm.load(token: "token")
        XCTAssertEqual(vm.sessions.count, 1)
        XCTAssertEqual(vm.sessions.first?.title, "Kuliah Aksesibilitas")
    }

    func testSessionDetailUpdatesNotes() async {
        let api = MockAPIClient()
        api.sessions = [TranscriptSession(
            id: "s1",
            title: "Kuliah Aksesibilitas",
            className: "Design",
            languageCode: "id-ID",
            fullText: "Halo semua.",
            notes: nil,
            startedAt: Date(),
            endedAt: Date(),
            createdAt: Date(),
            updatedAt: Date(),
            segments: []
        )]
        let vm = SessionDetailViewModel(apiClient: api, sessionId: "s1")
        await vm.load(token: "token")
        vm.notes = "Bagian ini penting."
        await vm.saveNotes(token: "token")
        XCTAssertEqual(vm.session?.notes, "Bagian ini penting.")
    }
}
