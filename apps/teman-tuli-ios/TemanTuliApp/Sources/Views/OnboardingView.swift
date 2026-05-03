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
                Section("Mulai Teman Tuli") {
                    TextField("Nama", text: $viewModel.name)
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    SecureField("Password", text: $viewModel.password)
                    TextField("Tujuan aksesibilitas", text: $viewModel.goal, axis: .vertical)
                }

                Section {
                    Button(viewModel.isLoading ? "Membuat akun..." : "Masuk") {
                        Task { await viewModel.register(session: session) }
                    }
                    .disabled(viewModel.isLoading || viewModel.name.isEmpty || viewModel.email.isEmpty || viewModel.password.count < 8)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }
            }
            .navigationTitle("Teman Tuli")
        }
    }
}
