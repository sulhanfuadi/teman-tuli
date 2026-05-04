import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var session: AppSession
    @AppStorage(APIEndpointConfig.storageKey) private var storedBaseURL: String = APIEndpointConfig.defaultBaseURLString
    @State private var draftBaseURL: String = ""
    @State private var endpointNotice: String?
    @State private var endpointError: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: TTSpacing.lg) {
                    BrandWordmarkView(subtitle: L10n.tr("settings.nav_title"))

                    SectionCard {
                        VStack(alignment: .leading, spacing: TTSpacing.sm) {
                            Text(L10n.tr("settings.section.accessibility"))
                                .font(TTTypography.headline)
                            InlineNotice(message: L10n.tr("settings.accessibility.large_caption"))
                            InlineNotice(message: L10n.tr("settings.accessibility.language"))
                            InlineNotice(message: L10n.tr("settings.accessibility.private_transcript"))
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: TTSpacing.sm) {
                            Text(L10n.tr("settings.section.api"))
                                .font(TTTypography.headline)

                            TextField(L10n.tr("settings.api.base_url"), text: $draftBaseURL)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .keyboardType(.URL)
                                .textFieldStyle(.roundedBorder)
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
                            .buttonStyle(PrimaryActionButtonStyle())
                            .accessibilityIdentifier("settings_save_endpoint_button")

                            InlineNotice(message: String(format: L10n.tr("settings.api.active"), APIEndpointConfig.currentBaseURLString()))
                                .accessibilityIdentifier("settings_active_endpoint_label")

                            if let endpointNotice {
                                StatusCard(style: .success, message: endpointNotice)
                                    .accessibilityIdentifier("settings_endpoint_notice")
                            }

                            if let endpointError {
                                StatusCard(style: .error, message: endpointError)
                                    .accessibilityIdentifier("settings_endpoint_error")
                            }
                        }
                    }

                    SectionCard {
                        Button(L10n.tr("settings.signout")) { session.signOut() }
                            .buttonStyle(SecondaryActionButtonStyle())
                            .foregroundStyle(TTColor.danger)
                            .accessibilityIdentifier("settings_signout_button")
                    }
                }
                .padding(TTSpacing.lg)
            }
            .background(TTColor.background.ignoresSafeArea())
            .navigationTitle(L10n.tr("settings.nav_title"))
            .onAppear {
                draftBaseURL = APIEndpointConfig.currentBaseURLString()
            }
        }
    }
}
