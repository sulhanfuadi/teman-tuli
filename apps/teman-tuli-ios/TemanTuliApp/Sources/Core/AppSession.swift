import Foundation
import SwiftUI

@MainActor
final class AppSession: ObservableObject {
    @AppStorage("temantuli.auth.token") private var storedToken: String = ""
    @Published var token: String? {
        didSet { storedToken = token ?? "" }
    }
    @Published var user: AuthUser?

    init() {
        token = storedToken.isEmpty ? nil : storedToken
    }

    var isAuthenticated: Bool { token != nil }

    func signOut() {
        token = nil
        user = nil
    }
}
