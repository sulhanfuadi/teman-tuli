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
                        Button("Tutup") { session.clearNotice() }
                    }
                }

                Section("Akses Akun") {
                    Picker("Mode", selection: $viewModel.authMode) {
                        ForEach(AuthMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("auth_mode_picker")
                }

                Section(viewModel.authMode == .register ? "Mulai Teman Tuli" : "Masuk ke Teman Tuli") {
                    if viewModel.authMode == .register {
                        TextField("Nama", text: $viewModel.name)
                            .accessibilityIdentifier("register_name_field")
                    }
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .accessibilityIdentifier("auth_email_field")
                    SecureField("Password", text: $viewModel.password)
                        .accessibilityIdentifier("auth_password_field")
                    if viewModel.authMode == .register {
                        TextField("Tujuan aksesibilitas", text: $viewModel.goal, axis: .vertical)
                            .accessibilityIdentifier("register_goal_field")
                    }
                }

                Section {
                    Button(viewModel.isLoading ? "Memproses..." : viewModel.authMode.rawValue) {
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
                                Text("Ref: \(ref)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Button("Copy Ref") {
                                    UIPasteboard.general.string = ref
                                }
                                .font(.caption)
                            }
                            .accessibilityIdentifier("auth_error_ref")
                        }
                    }
                }
            }
            .navigationTitle("Teman Tuli")
        }
    }
}
