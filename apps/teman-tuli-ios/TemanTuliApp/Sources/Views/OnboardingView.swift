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
            ScrollView {
                VStack(spacing: TTSpacing.lg) {
                    BrandWordmarkView(subtitle: L10n.tr("onboarding.hero_subtitle"))

                    if let notice = session.authNotice {
                        SectionCard {
                            VStack(alignment: .leading, spacing: TTSpacing.sm) {
                                InlineNotice(message: notice, style: .warning)
                                Button(L10n.tr("common.close")) { session.clearNotice() }
                                    .buttonStyle(SecondaryActionButtonStyle())
                            }
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: TTSpacing.sm) {
                            Text(L10n.tr("onboarding.account_access"))
                                .font(TTTypography.headline)
                            Picker(L10n.tr("common.mode"), selection: $viewModel.authMode) {
                                ForEach(AuthMode.allCases) { mode in
                                    Text(mode.localizedTitle).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .accessibilityIdentifier("auth_mode_picker")
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: TTSpacing.sm) {
                            Text(viewModel.authMode == .register ? L10n.tr("onboarding.register.title") : L10n.tr("onboarding.login.title"))
                                .font(TTTypography.headline)

                            if viewModel.authMode == .register {
                                TextField(L10n.tr("onboarding.name"), text: $viewModel.name)
                                    .textInputAutocapitalization(.words)
                                    .accessibilityIdentifier("register_name_field")
                                    .textFieldStyle(.roundedBorder)
                            }

                            TextField(L10n.tr("common.email"), text: $viewModel.email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .accessibilityIdentifier("auth_email_field")
                                .textFieldStyle(.roundedBorder)

                            SecureField(L10n.tr("common.password"), text: $viewModel.password)
                                .accessibilityIdentifier("auth_password_field")
                                .textFieldStyle(.roundedBorder)

                            if viewModel.authMode == .register {
                                TextField(L10n.tr("onboarding.goal"), text: $viewModel.goal, axis: .vertical)
                                    .accessibilityIdentifier("register_goal_field")
                                    .textFieldStyle(.roundedBorder)
                            }

                            Button(viewModel.isLoading ? L10n.tr("onboarding.processing") : viewModel.authMode.localizedTitle) {
                                Task { await viewModel.submit(session: session) }
                            }
                            .buttonStyle(PrimaryActionButtonStyle())
                            .disabled(viewModel.isLoading || !viewModel.canSubmit)
                            .accessibilityIdentifier("auth_submit_button")
                        }
                    }

                    if let errorMessage = viewModel.errorMessage {
                        SectionCard {
                            VStack(alignment: .leading, spacing: TTSpacing.sm) {
                                StatusCard(style: .error, message: errorMessage)
                                    .accessibilityIdentifier("auth_error_message")
                                if let ref = viewModel.errorRequestReference {
                                    HStack {
                                        Text(String(format: L10n.tr("common.ref"), ref))
                                            .font(TTTypography.caption)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Button(L10n.tr("common.copy_ref")) {
                                            UIPasteboard.general.string = ref
                                        }
                                        .font(TTTypography.caption)
                                    }
                                    .accessibilityIdentifier("auth_error_ref")
                                }
                            }
                        }
                    }
                }
                .padding(TTSpacing.lg)
            }
            .background(TTColor.background.ignoresSafeArea())
            .navigationTitle(L10n.tr("app.title"))
        }
    }
}
