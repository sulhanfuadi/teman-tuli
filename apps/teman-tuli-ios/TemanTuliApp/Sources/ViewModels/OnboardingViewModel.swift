import Foundation

enum AuthMode: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case register
    case login
}

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var authMode: AuthMode = .register
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var goal: String = "Akses caption kelas yang lebih inklusif"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var errorRequestReference: String?

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    var canSubmit: Bool {
        switch authMode {
        case .register:
            return !name.isEmpty && !email.isEmpty && password.count >= 8
        case .login:
            return !email.isEmpty && password.count >= 8
        }
    }

    func submit(session: AppSession) async {
        guard !isLoading else { return }

        errorMessage = nil
        errorRequestReference = nil
        session.clearNotice()
        isLoading = true
        defer { isLoading = false }

        do {
            let result: (AuthUser, String)
            switch authMode {
            case .register:
                result = try await apiClient.register(
                    name: name,
                    email: email,
                    password: password,
                    goal: goal.isEmpty ? nil : goal
                )
            case .login:
                result = try await apiClient.login(email: email, password: password)
            }

            session.user = result.0
            session.token = result.1
            session.clearNotice()
        } catch let error as APIError {
            let mapped = mapError(error)
            errorMessage = mapped.message
            errorRequestReference = mapped.requestReference
        } catch {
            errorMessage = "Autentikasi gagal. Coba lagi."
            errorRequestReference = nil
        }
    }

    private func mapError(_ error: APIError) -> APIErrorPresentation {
        switch error {
        case .unauthorized:
            return APIErrorPresentation(message: "Email atau password tidak sesuai.", requestReference: nil)
        default:
            return APIErrorMessageFormatter.presentation(
                for: error,
                networkMessage: "Tidak bisa terhubung ke server. Periksa koneksi internet/backend.",
                fallbackMessage: "Terjadi kesalahan saat autentikasi."
            )
        }
    }
}
