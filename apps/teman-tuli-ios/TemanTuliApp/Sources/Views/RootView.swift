import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: AppSession
    let apiClient: APIClient

    var body: some View {
        if session.isAuthenticated {
            TabView {
                LiveCaptionView(apiClient: apiClient)
                    .tabItem { Label("Caption", systemImage: "captions.bubble") }

                SessionsView(apiClient: apiClient)
                    .tabItem { Label("Transkrip", systemImage: "doc.text") }

                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape") }
            }
        } else {
            OnboardingView(apiClient: apiClient)
        }
    }
}
