import Foundation

@MainActor
final class SessionDetailViewModel: ObservableObject {
    @Published var session: TranscriptSession?
    @Published var notes: String = ""
    @Published var feedbackComment: String = ""
    @Published var selectedRating: CaptionFeedbackRating = .good
    @Published var isLoading: Bool = false
    @Published var isSavingNotes: Bool = false
    @Published var isSubmittingFeedback: Bool = false
    @Published var message: String?
    @Published var errorMessage: String?
    @Published var errorRequestReference: String?

    private let apiClient: APIClient
    private let sessionId: String

    init(apiClient: APIClient, sessionId: String) {
        self.apiClient = apiClient
        self.sessionId = sessionId
    }

    func load(token: String, appSession: AppSession) async {
        isLoading = true
        errorMessage = nil
        errorRequestReference = nil
        defer { isLoading = false }

        do {
            session = try await apiClient.fetchSession(token: token, id: sessionId)
            notes = session?.notes ?? ""
        } catch let error as APIError {
            if error == .unauthorized {
                appSession.expireAuth()
                return
            }
            let mapped = mapError(error)
            errorMessage = mapped.message
            errorRequestReference = mapped.requestReference
        } catch {
            errorMessage = L10n.tr("detail.load_failed")
            errorRequestReference = nil
        }
    }

    func saveNotes(token: String, appSession: AppSession) async {
        guard !isSavingNotes else { return }
        guard let session else { return }

        isSavingNotes = true
        defer { isSavingNotes = false }

        do {
            self.session = try await apiClient.updateSession(
                token: token,
                id: session.id,
                title: session.title,
                className: session.className,
                notes: notes.isEmpty ? nil : notes
            )
            message = L10n.tr("detail.notes_updated")
            errorMessage = nil
            errorRequestReference = nil
        } catch let error as APIError {
            if error == .unauthorized {
                appSession.expireAuth()
                return
            }
            let mapped = mapError(error)
            errorMessage = mapped.message
            errorRequestReference = mapped.requestReference
        } catch {
            errorMessage = L10n.tr("detail.notes_update_failed")
            errorRequestReference = nil
        }
    }

    func submitFeedback(token: String, appSession: AppSession) async {
        guard !isSubmittingFeedback else { return }
        guard let session else { return }

        isSubmittingFeedback = true
        defer { isSubmittingFeedback = false }

        do {
            try await apiClient.submitFeedback(
                token: token,
                sessionId: session.id,
                rating: selectedRating,
                comment: feedbackComment.isEmpty ? nil : feedbackComment
            )
            message = L10n.tr("detail.feedback_saved")
            feedbackComment = ""
            errorMessage = nil
            errorRequestReference = nil
        } catch let error as APIError {
            if error == .unauthorized {
                appSession.expireAuth()
                return
            }
            let mapped = mapError(error)
            errorMessage = mapped.message
            errorRequestReference = mapped.requestReference
        } catch {
            errorMessage = L10n.tr("detail.feedback_failed")
            errorRequestReference = nil
        }
    }

    private func mapError(_ error: APIError) -> APIErrorPresentation {
        APIErrorMessageFormatter.presentation(
            for: error,
            networkMessage: L10n.tr("detail.network_failed"),
            fallbackMessage: L10n.tr("detail.fallback_error")
        )
    }
}
