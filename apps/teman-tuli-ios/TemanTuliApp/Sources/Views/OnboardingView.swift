import SwiftUI
import UIKit

struct OnboardingView: View {
    @EnvironmentObject private var session: AppSession
    @StateObject private var viewModel: OnboardingViewModel

    init(apiClient: APIClient) {
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(apiClient: apiClient))
    }

    var body: some View {
        NavigationStack {
            Form {
                if let notice = session.authNotice {
                    Section {
                        Label(notice, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                        Button(L10n.tr("common.close")) { session.clearNotice() }
                    }
                }

                Section(L10n.tr("onboarding.account_access")) {
                    Picker(L10n.tr("common.mode"), selection: $viewModel.authMode) {
                        ForEach(AuthMode.allCases) { mode in
                            Text(mode.localizedTitle).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("auth_mode_picker")
                }

                Section(viewModel.authMode == .register ? L10n.tr("onboarding.register.title") : L10n.tr("onboarding.login.title")) {
                    if viewModel.authMode == .register {
                        TextField(L10n.tr("onboarding.name"), text: $viewModel.name)
                            .accessibilityIdentifier("register_name_field")
                    }
                    TextField(L10n.tr("common.email"), text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .accessibilityIdentifier("auth_email_field")
                    SecureField(L10n.tr("common.password"), text: $viewModel.password)
                        .accessibilityIdentifier("auth_password_field")
                    if viewModel.authMode == .register {
                        TextField(L10n.tr("onboarding.goal"), text: $viewModel.goal, axis: .vertical)
                            .accessibilityIdentifier("register_goal_field")
                    }
                }

                Section {
                    Button(viewModel.isLoading ? L10n.tr("onboarding.processing") : viewModel.authMode.localizedTitle) {
                        Task { await viewModel.submit(session: session) }
                    }
                    .disabled(viewModel.isLoading || !viewModel.canSubmit)
                    .accessibilityIdentifier("auth_submit_button")
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .accessibilityIdentifier("auth_error_message")
                        if let ref = viewModel.errorRequestReference {
                            HStack {
                                Text(String(format: L10n.tr("common.ref"), ref))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Button(L10n.tr("common.copy_ref")) {
                                    UIPasteboard.general.string = ref
                                }
                                .font(.caption)
                            }
                            .accessibilityIdentifier("auth_error_ref")
                        }
                    }
                }
            }
            .navigationTitle(L10n.tr("app.title"))
        }
    }
}
