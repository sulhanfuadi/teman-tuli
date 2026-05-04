import XCTest
@testable import TemanTuli

final class MockAPIClient: APIClient {
    var sessions: [TranscriptSession] = []
    var unauthorizedOnFetchSessions: Bool = false
    var unauthorizedOnCreateSession: Bool = false
    var unauthorizedOnFetchSession: Bool = false
    var unauthorizedOnUpdateSession: Bool = false
    var unauthorizedOnFeedback: Bool = false
    var unauthorizedOnDeleteSession: Bool = false

    func register(name: String, email: String, password: String, goal: String?) async throws -> (AuthUser, String) {
        (AuthUser(id: "u1", name: name, email: email, goal: goal), "token")
    }

    func login(email: String, password: String) async throws -> (AuthUser, String) {
        (AuthUser(id: "u1", name: "User", email: email, goal: nil), "token")
    }

    func fetchSessions(token: String) async throws -> [TranscriptSession] {
        if unauthorizedOnFetchSessions { throw APIError.unauthorized }
        return sessions
    }

    func createSession(token: String, payload: NewTranscriptSession) async throws -> TranscriptSession {
        if unauthorizedOnCreateSession { throw APIError.unauthorized }
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
        if unauthorizedOnFetchSession { throw APIError.unauthorized }
        return sessions.first { $0.id == id }!
    }

    func updateSession(token: String, id: String, title: String?, className: String?, notes: String?) async throws -> TranscriptSession {
        if unauthorizedOnUpdateSession { throw APIError.unauthorized }
        let index = sessions.firstIndex { $0.id == id }!
        sessions[index].notes = notes
        return sessions[index]
    }

    func deleteSession(token: String, id: String) async throws {
        if unauthorizedOnDeleteSession { throw APIError.unauthorized }
        sessions.removeAll { $0.id == id }
    }

    func submitFeedback(token: String, sessionId: String, rating: CaptionFeedbackRating, comment: String?) async throws {
        if unauthorizedOnFeedback { throw APIError.unauthorized }
    }
}

@MainActor
final class ViewModelTests: XCTestCase {
    func testSessionsLoadPrivateArchive() async {
        let api = MockAPIClient()
        api.sessions = [sampleSession(id: "s1")]
        let vm = SessionsViewModel(apiClient: api)
        let appSession = AppSession()

        await vm.load(token: "token", session: appSession)

        XCTAssertEqual(vm.sessions.count, 1)
        XCTAssertEqual(vm.sessions.first?.title, "Kuliah Aksesibilitas")
    }

    func testSessionDetailUpdatesNotes() async {
        let api = MockAPIClient()
        api.sessions = [sampleSession(id: "s1")]
        let vm = SessionDetailViewModel(apiClient: api, sessionId: "s1")
        let appSession = AppSession()

        await vm.load(token: "token", appSession: appSession)
        vm.notes = "Bagian ini penting."
        await vm.saveNotes(token: "token", appSession: appSession)

        XCTAssertEqual(vm.session?.notes, "Bagian ini penting.")
    }

    func testUnauthorizedSessionLoadExpiresAuth() async {
        let api = MockAPIClient()
        api.unauthorizedOnFetchSessions = true
        let vm = SessionsViewModel(apiClient: api)
        let appSession = AppSession()
        appSession.token = "active-token"

        await vm.load(token: "active-token", session: appSession)

        XCTAssertNil(appSession.token)
        XCTAssertEqual(appSession.authNotice, "Sesi berakhir. Silakan login kembali.")
    }

    func testUnauthorizedSaveTranscriptExpiresAuth() async {
        let api = MockAPIClient()
        api.unauthorizedOnCreateSession = true
        let speechService = SpeechCaptionService()
        speechService.liveText = "Ini transkrip penting"
        let vm = LiveCaptionViewModel(apiClient: api, speechService: speechService)
        let appSession = AppSession()
        appSession.token = "active-token"

        await vm.saveTranscript(token: "active-token", session: appSession)

        XCTAssertNil(appSession.token)
        XCTAssertEqual(appSession.authNotice, "Sesi berakhir. Silakan login kembali.")
    }

    func testUnauthorizedSessionDetailLoadExpiresAuth() async {
        let api = MockAPIClient()
        api.unauthorizedOnFetchSession = true
        api.sessions = [sampleSession(id: "s1")]
        let vm = SessionDetailViewModel(apiClient: api, sessionId: "s1")
        let appSession = AppSession()
        appSession.token = "active-token"

        await vm.load(token: "active-token", appSession: appSession)

        XCTAssertNil(appSession.token)
        XCTAssertEqual(appSession.authNotice, "Sesi berakhir. Silakan login kembali.")
    }

    func testUnauthorizedSaveNotesExpiresAuth() async {
        let api = MockAPIClient()
        api.sessions = [sampleSession(id: "s1")]
        api.unauthorizedOnUpdateSession = true
        let vm = SessionDetailViewModel(apiClient: api, sessionId: "s1")
        let appSession = AppSession()
        appSession.token = "active-token"

        await vm.load(token: "active-token", appSession: appSession)
        vm.notes = "Catatan baru"
        await vm.saveNotes(token: "active-token", appSession: appSession)

        XCTAssertNil(appSession.token)
        XCTAssertEqual(appSession.authNotice, "Sesi berakhir. Silakan login kembali.")
    }

    func testUnauthorizedFeedbackExpiresAuth() async {
        let api = MockAPIClient()
        api.sessions = [sampleSession(id: "s1")]
        api.unauthorizedOnFeedback = true
        let vm = SessionDetailViewModel(apiClient: api, sessionId: "s1")
        let appSession = AppSession()
        appSession.token = "active-token"

        await vm.load(token: "active-token", appSession: appSession)
        await vm.submitFeedback(token: "active-token", appSession: appSession)

        XCTAssertNil(appSession.token)
        XCTAssertEqual(appSession.authNotice, "Sesi berakhir. Silakan login kembali.")
    }

    func testDeleteSessionRemovesItemFromLocalState() async {
        let api = MockAPIClient()
        api.sessions = [sampleSession(id: "s1"), sampleSession(id: "s2")]
        let vm = SessionsViewModel(apiClient: api)
        vm.sessions = api.sessions
        let appSession = AppSession()
        appSession.token = "active-token"

        await vm.deleteSession(id: "s1", token: "active-token", session: appSession)

        XCTAssertEqual(vm.sessions.count, 1)
        XCTAssertEqual(vm.sessions.first?.id, "s2")
        XCTAssertEqual(vm.successMessage, "Transkrip berhasil dihapus.")
    }

    func testUnauthorizedDeleteSessionExpiresAuth() async {
        let api = MockAPIClient()
        api.sessions = [sampleSession(id: "s1")]
        api.unauthorizedOnDeleteSession = true
        let vm = SessionsViewModel(apiClient: api)
        vm.sessions = api.sessions
        let appSession = AppSession()
        appSession.token = "active-token"

        await vm.deleteSession(id: "s1", token: "active-token", session: appSession)

        XCTAssertNil(appSession.token)
        XCTAssertEqual(appSession.authNotice, "Sesi berakhir. Silakan login kembali.")
    }

    func testEndpointConfigSavesValidURL() {
        let store = UserDefaults(suiteName: "TemanTuli.EndpointConfig.Valid")!
        store.removePersistentDomain(forName: "TemanTuli.EndpointConfig.Valid")

        let saved = APIEndpointConfig.saveBaseURL("http://127.0.0.1:3301/api/v1", store: store)

        XCTAssertTrue(saved)
        XCTAssertEqual(APIEndpointConfig.currentBaseURLString(store: store), "http://127.0.0.1:3301/api/v1")
    }

    func testEndpointConfigRejectsInvalidURLAndKeepsLastValidValue() {
        let store = UserDefaults(suiteName: "TemanTuli.EndpointConfig.Invalid")!
        store.removePersistentDomain(forName: "TemanTuli.EndpointConfig.Invalid")
        _ = APIEndpointConfig.saveBaseURL("http://localhost:3000/api/v1", store: store)

        let saved = APIEndpointConfig.saveBaseURL("not-a-url", store: store)

        XCTAssertFalse(saved)
        XCTAssertEqual(APIEndpointConfig.currentBaseURLString(store: store), "http://localhost:3000/api/v1")
    }

    func testErrorMessageFormatterMapsRateLimitedWithRequestRef() {
        let error = APIError.serverError(
            statusCode: 429,
            code: "RATE_LIMITED",
            message: "Too many requests",
            requestId: "req-123456789"
        )

        let message = APIErrorMessageFormatter.friendlyMessage(
            for: error,
            networkMessage: "network",
            fallbackMessage: "fallback"
        )

        XCTAssertTrue(message.contains("Terlalu banyak permintaan"))
        XCTAssertTrue(message.contains("Ref: req-1234"))
    }

    private func sampleSession(id: String) -> TranscriptSession {
        TranscriptSession(
            id: id,
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
        )
    }
}
