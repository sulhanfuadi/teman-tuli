import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var session: AppSession
    @AppStorage(APIEndpointConfig.storageKey) private var storedBaseURL: String = APIEndpointConfig.defaultBaseURLString
    @State private var draftBaseURL: String = ""
    @State private var endpointNotice: String?
    @State private var endpointError: String?
    @State private var showDeveloperOptions: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    BrandWordmarkView(subtitle: L10n.tr("settings.nav_title"))
                        .padding(.vertical, TTSpacing.xs)
                        .listRowInsets(EdgeInsets(top: TTSpacing.sm, leading: TTSpacing.md, bottom: TTSpacing.sm, trailing: TTSpacing.md))
                }

                Section(L10n.tr("settings.section.accessibility")) {
                    Label(L10n.tr("settings.accessibility.large_caption"), systemImage: "captions.bubble")
                    Label(L10n.tr("settings.accessibility.language"), systemImage: "globe")
                    Label(L10n.tr("settings.accessibility.private_transcript"), systemImage: "lock.shield")
                }

#if DEBUG
                Section {
                    DisclosureGroup(isExpanded: $showDeveloperOptions) {
                        VStack(alignment: .leading, spacing: TTSpacing.sm) {
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
                        .padding(.top, TTSpacing.xs)
                    } label: {
                        Label(L10n.tr("settings.section.developer"), systemImage: "hammer")
                    }
                }
#endif

                Section {
                    Button(role: .destructive) { session.signOut() } label: {
                        Text(L10n.tr("settings.signout"))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .accessibilityIdentifier("settings_signout_button")
                }
            }
            .scrollContentBackground(.hidden)
            .background(TTColor.background.ignoresSafeArea())
            .listStyle(.insetGrouped)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                draftBaseURL = APIEndpointConfig.currentBaseURLString()
            }
        }
    }
}
