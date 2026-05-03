import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var goal: String = "Akses caption kelas yang lebih inklusif"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func register(session: AppSession) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await apiClient.register(name: name, email: email, password: password, goal: goal.isEmpty ? nil : goal)
            session.user = result.0
            session.token = result.1
        } catch {
            errorMessage = "Registrasi gagal. Periksa email, password, dan koneksi backend."
        }
    }
}
