import SwiftUI

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
                }

                Section(viewModel.authMode == .register ? "Mulai Teman Tuli" : "Masuk ke Teman Tuli") {
                    if viewModel.authMode == .register {
                        TextField("Nama", text: $viewModel.name)
                    }
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    SecureField("Password", text: $viewModel.password)
                    if viewModel.authMode == .register {
                        TextField("Tujuan aksesibilitas", text: $viewModel.goal, axis: .vertical)
                    }
                }

                Section {
                    Button(viewModel.isLoading ? "Memproses..." : viewModel.authMode.rawValue) {
                        Task { await viewModel.submit(session: session) }
                    }
                    .disabled(viewModel.isLoading || !viewModel.canSubmit)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }
            }
            .navigationTitle("Teman Tuli")
        }
    }
}
