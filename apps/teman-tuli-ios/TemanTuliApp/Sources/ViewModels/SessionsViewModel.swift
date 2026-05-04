import Foundation

@MainActor
final class SessionsViewModel: ObservableObject {
    @Published var sessions: [TranscriptSession] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func load(token: String, session: AppSession) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        defer { isLoading = false }

        do {
            sessions = try await apiClient.fetchSessions(token: token)
        } catch let error as APIError {
            if error == .unauthorized {
                session.expireAuth()
                return
            }
            errorMessage = mapError(error)
        } catch {
            errorMessage = "Gagal memuat daftar transkrip."
        }
    }

    func deleteSession(id: String, token: String, session: AppSession) async {
        errorMessage = nil
        successMessage = nil

        do {
            try await apiClient.deleteSession(token: token, id: id)
            sessions.removeAll { $0.id == id }
            successMessage = "Transkrip berhasil dihapus."
        } catch let error as APIError {
            if error == .unauthorized {
                session.expireAuth()
                return
            }
            errorMessage = mapError(error)
        } catch {
            errorMessage = "Gagal menghapus transkrip."
        }
    }

    private func mapError(_ error: APIError) -> String {
        switch error {
        case .networkUnavailable:
            return "Tidak bisa mengambil transkrip. Periksa koneksi/backend."
        case .serverError(let statusCode, _, _, _):
            return "Gagal memproses permintaan (server \(statusCode))."
        default:
            return "Gagal memuat daftar transkrip."
        }
    }
}
