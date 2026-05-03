import SwiftUI

struct SessionDetailView: View {
    @EnvironmentObject private var session: AppSession
    @StateObject private var viewModel: SessionDetailViewModel

    init(apiClient: APIClient, sessionId: String) {
        _viewModel = StateObject(wrappedValue: SessionDetailViewModel(apiClient: apiClient, sessionId: sessionId))
    }

    var body: some View {
        Form {
            if let transcript = viewModel.session {
                Section("Informasi") {
                    LabeledContent("Judul", value: transcript.title)
                    LabeledContent("Kelas", value: transcript.className ?? "-")
                    LabeledContent("Bahasa", value: transcript.languageCode)
                }

                Section("Transkrip") {
                    Text(transcript.fullText)
                        .font(.body)
                        .textSelection(.enabled)
                }

                Section("Catatan Pribadi") {
                    TextField("Tambahkan konteks penting dari kelas", text: $viewModel.notes, axis: .vertical)
                    Button("Simpan Catatan") {
                        guard let token = session.token else { return }
                        Task { await viewModel.saveNotes(token: token) }
                    }
                }

                Section("Feedback Kualitas Caption") {
                    Picker("Rating", selection: $viewModel.selectedRating) {
                        ForEach(CaptionFeedbackRating.allCases) { rating in
                            Text(rating.rawValue).tag(rating)
                        }
                    }
                    TextField("Apa yang perlu diperbaiki?", text: $viewModel.feedbackComment, axis: .vertical)
                    Button("Kirim Feedback") {
                        guard let token = session.token else { return }
                        Task { await viewModel.submitFeedback(token: token) }
                    }
                }
            } else if viewModel.isLoading {
                ProgressView("Memuat detail...")
            } else {
                Text(viewModel.errorMessage ?? "Transkrip tidak ditemukan.")
                    .foregroundStyle(.secondary)
            }

            if let message = viewModel.message { Text(message).foregroundStyle(.green) }
            if let errorMessage = viewModel.errorMessage { Text(errorMessage).foregroundStyle(.red) }
        }
        .navigationTitle("Detail Transkrip")
        .task {
            guard let token = session.token else { return }
            await viewModel.load(token: token)
        }
    }
}
