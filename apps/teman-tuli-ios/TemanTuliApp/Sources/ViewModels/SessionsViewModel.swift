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

    func load(token: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            sessions = try await apiClient.fetchSessions(token: token)
        } catch {
            errorMessage = "Gagal memuat daftar transkrip."
        }
    }
}
