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

    init() {
        token = storedToken.isEmpty ? nil : storedToken
    }

    var isAuthenticated: Bool { token != nil }

    func signOut() {
        token = nil
        user = nil
    }

    func expireAuth(message: String = "Sesi berakhir. Silakan login kembali.") {
        signOut()
        authNotice = message
    }

    func clearNotice() {
        authNotice = nil
    }
}
