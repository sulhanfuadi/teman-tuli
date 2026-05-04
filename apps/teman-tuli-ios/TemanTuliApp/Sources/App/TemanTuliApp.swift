import SwiftUI

@main
struct TemanTuliApp: App {
    @StateObject private var session: AppSession
    private let apiClient: APIClient
    private let runtimeConfig: UITestRuntimeConfig

    init() {
        let config = UITestRuntimeConfig.current
        runtimeConfig = config

        if let mockURL = config.mockAPIBaseURL {
            _ = APIEndpointConfig.saveBaseURL(mockURL)
        }

        _session = StateObject(wrappedValue: AppSession(mockAuthenticated: config.isUITestMode && config.mockAuthenticated))

        if config.isUITestMode {
            apiClient = UITestHarnessAPIClient()
        } else {
            apiClient = LiveAPIClient(baseURLProvider: {
                if let mock = config.mockAPIBaseURL, let url = URL(string: mock) {
                    return url
                }
                return APIEndpointConfig.currentBaseURL()
            })
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(apiClient: apiClient, runtimeConfig: runtimeConfig)
                .environmentObject(session)
        }
    }
}
