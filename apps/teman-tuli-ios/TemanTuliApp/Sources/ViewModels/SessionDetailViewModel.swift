import Foundation

@MainActor
final class SessionDetailViewModel: ObservableObject {
    @Published var session: TranscriptSession?
    @Published var notes: String = ""
    @Published var feedbackComment: String = ""
    @Published var selectedRating: CaptionFeedbackRating = .good
    @Published var isLoading: Bool = false
    @Published var message: String?
    @Published var errorMessage: String?

    private let apiClient: APIClient
    private let sessionId: String

    init(apiClient: APIClient, sessionId: String) {
        self.apiClient = apiClient
        self.sessionId = sessionId
    }

    func load(token: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            session = try await apiClient.fetchSession(token: token, id: sessionId)
            notes = session?.notes ?? ""
        } catch {
            errorMessage = "Gagal memuat detail transkrip."
        }
    }

    func saveNotes(token: String) async {
        guard let session else { return }
        do {
            self.session = try await apiClient.updateSession(
                token: token,
                id: session.id,
                title: session.title,
                className: session.className,
                notes: notes.isEmpty ? nil : notes
            )
            message = "Catatan diperbarui."
        } catch {
            errorMessage = "Gagal memperbarui catatan."
        }
    }

    func submitFeedback(token: String) async {
        guard let session else { return }
        do {
            try await apiClient.submitFeedback(token: token, sessionId: session.id, rating: selectedRating, comment: feedbackComment.isEmpty ? nil : feedbackComment)
            message = "Feedback caption tersimpan."
            feedbackComment = ""
        } catch {
            errorMessage = "Gagal mengirim feedback."
        }
    }
}
