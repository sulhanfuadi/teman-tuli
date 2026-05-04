import Foundation

@MainActor
final class SessionsViewModel: ObservableObject {
    @Published var sessions: [TranscriptSession] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var errorRequestReference: String?
    @Published var successMessage: String?
    @Published var isDeletingSession: Bool = false

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func load(token: String, session: AppSession) async {
        isLoading = true
        errorMessage = nil
        errorRequestReference = nil
        successMessage = nil
        defer { isLoading = false }

        do {
            sessions = try await apiClient.fetchSessions(token: token)
        } catch let error as APIError {
            if error == .unauthorized {
                session.expireAuth()
                return
            }
            let mapped = mapLoadError(error)
            errorMessage = mapped.message
            errorRequestReference = mapped.requestReference
        } catch {
            errorMessage = "Gagal memuat daftar transkrip."
            errorRequestReference = nil
        }
    }

    func deleteSession(id: String, token: String, session: AppSession) async {
        guard !isDeletingSession else { return }

        isDeletingSession = true
        errorMessage = nil
        errorRequestReference = nil
        successMessage = nil
        defer { isDeletingSession = false }

        do {
            try await apiClient.deleteSession(token: token, id: id)
            sessions.removeAll { $0.id == id }
            successMessage = "Transkrip berhasil dihapus."
        } catch let error as APIError {
            if error == .unauthorized {
                session.expireAuth()
                return
            }
            let mapped = mapDeleteError(error)
            errorMessage = mapped.message
            errorRequestReference = mapped.requestReference
        } catch {
            errorMessage = "Gagal menghapus transkrip."
            errorRequestReference = nil
        }
    }

    private func mapLoadError(_ error: APIError) -> APIErrorPresentation {
        APIErrorMessageFormatter.presentation(
            for: error,
            networkMessage: "Tidak bisa mengambil transkrip. Periksa koneksi/backend.",
            fallbackMessage: "Gagal memuat daftar transkrip."
        )
    }

    private func mapDeleteError(_ error: APIError) -> APIErrorPresentation {
        APIErrorMessageFormatter.presentation(
            for: error,
            networkMessage: "Tidak bisa menghapus transkrip. Periksa koneksi/backend.",
            fallbackMessage: "Gagal menghapus transkrip."
        )
    }
}
