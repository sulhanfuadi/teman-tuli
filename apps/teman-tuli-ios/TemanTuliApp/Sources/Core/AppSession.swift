import Foundation
import SwiftUI

@MainActor
final class AppSession: ObservableObject {
    @AppStorage("temantuli.auth.token") private var storedToken: String = ""
    @Published var token: String? {
        didSet { storedToken = token ?? "" }
    }
    @Published var user: AuthUser?
    @Published var authNotice: String?

    init(mockAuthenticated: Bool = false) {
        token = storedToken.isEmpty ? nil : storedToken

        if mockAuthenticated {
            token = "uitest-token"
            user = AuthUser(id: "uitest-user", name: "UITest User", email: "uitest@example.com", goal: nil)
        }
    }

    var isAuthenticated: Bool { token != nil }

    func signOut() {
        token = nil
        user = nil
    }

    func expireAuth(message: String = L10n.tr("error.unauthorized")) {
        signOut()
        authNotice = message
    }

    func clearNotice() {
        authNotice = nil
    }
}
