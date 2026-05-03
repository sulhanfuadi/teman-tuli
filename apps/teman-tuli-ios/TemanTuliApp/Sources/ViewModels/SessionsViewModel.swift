import Foundation

@MainActor
final class SessionsViewModel: ObservableObject {
    @Published var sessions: [TranscriptSession] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func load(token: String, session: AppSession) async {
        isLoading = true
        errorMessage = nil
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

    private func mapError(_ error: APIError) -> String {
        switch error {
        case .networkUnavailable:
            return "Tidak bisa mengambil transkrip. Periksa koneksi/backend."
        case .serverError(let code):
            return "Gagal memuat transkrip (server \(code))."
        default:
            return "Gagal memuat daftar transkrip."
        }
    }
}
