import SwiftUI

@main
struct TemanTuliApp: App {
    @StateObject private var session = AppSession()
    private let apiClient: APIClient = LiveAPIClient()

    var body: some Scene {
        WindowGroup {
            RootView(apiClient: apiClient)
                .environmentObject(session)
        }
    }
}
