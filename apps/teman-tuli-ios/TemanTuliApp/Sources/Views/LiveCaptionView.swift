import SwiftUI

struct LiveCaptionView: View {
    @EnvironmentObject private var session: AppSession
    @StateObject private var viewModel: LiveCaptionViewModel

    init(apiClient: APIClient) {
        _viewModel = StateObject(wrappedValue: LiveCaptionViewModel(apiClient: apiClient))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Judul sesi", text: $viewModel.title)
                            .textFieldStyle(.roundedBorder)
                        TextField("Nama kelas (opsional)", text: $viewModel.className)
                            .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Live Caption")
                            .font(.headline)
                        Text(viewModel.speechService.liveText.isEmpty ? "Tekan Mulai Caption untuk menampilkan transkrip kelas di sini." : viewModel.speechService.liveText)
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                            .lineSpacing(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .accessibilityLabel("Teks caption langsung")
                    }

                    TextField("Catatan pribadi setelah kelas (opsional)", text: $viewModel.notes, axis: .vertical)
                        .textFieldStyle(.roundedBorder)

                    HStack {
                        Button(viewModel.speechService.isRecording ? "Sedang merekam" : "Mulai Caption") {
                            Task { await viewModel.startCaptioning() }
                        }
                        .disabled(viewModel.speechService.isRecording)

                        Button("Berhenti") { viewModel.stopCaptioning() }
                            .disabled(!viewModel.speechService.isRecording)

                        Button(viewModel.isSaving ? "Menyimpan..." : "Simpan Privat") {
                            guard let token = session.token else { return }
                            Task { await viewModel.saveTranscript(token: token) }
                        }
                        .disabled(viewModel.isSaving || viewModel.speechService.isRecording)
                    }
                    .buttonStyle(.borderedProminent)

                    privacyCard

                    if let message = viewModel.saveMessage {
                        Text(message).foregroundStyle(.green)
                    }
                    if let message = viewModel.speechService.permissionMessage ?? viewModel.errorMessage {
                        Text(message).foregroundStyle(.red)
                    }
                }
                .padding()
            }
            .navigationTitle("Live Caption")
        }
    }

    private var privacyCard: some View {
        Label("Transkrip tidak diunggah otomatis. Kamu hanya menyimpan ke backend setelah menekan Simpan Privat.", systemImage: "lock.shield")
            .font(.callout)
            .foregroundStyle(.secondary)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.blue.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
