import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: AppSession
    let apiClient: APIClient
    let runtimeConfig: UITestRuntimeConfig

    var body: some View {
        Group {
            if session.isAuthenticated {
                TabView {
                    LiveCaptionView(apiClient: apiClient, runtimeConfig: runtimeConfig)
                        .tabItem { Label(L10n.tr("tab.caption"), systemImage: "captions.bubble") }

                    SessionsView(apiClient: apiClient)
                        .tabItem { Label(L10n.tr("tab.transcripts"), systemImage: "doc.text") }

                    SettingsView()
                        .tabItem { Label(L10n.tr("tab.settings"), systemImage: "gearshape") }
                }
            } else {
                OnboardingView(apiClient: apiClient)
            }
        }
        .tint(TTColor.brand)
    }
}
