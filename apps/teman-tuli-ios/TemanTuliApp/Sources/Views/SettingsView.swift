import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var session: AppSession
    @AppStorage(APIEndpointConfig.storageKey) private var storedBaseURL: String = APIEndpointConfig.defaultBaseURLString
    @State private var draftBaseURL: String = ""
    @State private var endpointNotice: String?
    @State private var endpointError: String?

    var body: some View {
        NavigationStack {
            Form {
                Section(L10n.tr("settings.section.accessibility")) {
                    Label(L10n.tr("settings.accessibility.large_caption"), systemImage: "textformat.size")
                    Label(L10n.tr("settings.accessibility.language"), systemImage: "globe")
                    Label(L10n.tr("settings.accessibility.private_transcript"), systemImage: "lock")
                }

                Section(L10n.tr("settings.section.api")) {
                    TextField(L10n.tr("settings.api.base_url"), text: $draftBaseURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.URL)
                        .accessibilityIdentifier("settings_api_base_url_field")

                    Button(L10n.tr("settings.api.save_endpoint")) {
                        let saved = APIEndpointConfig.saveBaseURL(draftBaseURL)
                        if saved {
                            storedBaseURL = APIEndpointConfig.currentBaseURLString()
                            draftBaseURL = storedBaseURL
                            endpointError = nil
                            endpointNotice = L10n.tr("settings.api.updated")
                        } else {
                            endpointNotice = nil
                            endpointError = L10n.tr("settings.api.invalid")
                        }
                    }
                    .accessibilityIdentifier("settings_save_endpoint_button")

                    Text(String(format: L10n.tr("settings.api.active"), APIEndpointConfig.currentBaseURLString()))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("settings_active_endpoint_label")

                    if let endpointNotice {
                        Text(endpointNotice)
                            .font(.caption)
                            .foregroundStyle(.green)
                            .accessibilityIdentifier("settings_endpoint_notice")
                    }

                    if let endpointError {
                        Text(endpointError)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .accessibilityIdentifier("settings_endpoint_error")
                    }
                }

                Section(L10n.tr("settings.section.account")) {
                    Button(L10n.tr("settings.signout")) { session.signOut() }
                        .foregroundStyle(.red)
                        .accessibilityIdentifier("settings_signout_button")
                }
            }
            .navigationTitle(L10n.tr("settings.nav_title"))
            .onAppear {
                draftBaseURL = APIEndpointConfig.currentBaseURLString()
            }
        }
    }
}
