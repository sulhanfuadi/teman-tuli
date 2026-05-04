import SwiftUI
import UIKit

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
                        .accessibilityIdentifier("detail_transcript_text")
                }

                Section("Catatan Pribadi") {
                    TextField("Tambahkan konteks penting dari kelas", text: $viewModel.notes, axis: .vertical)
                        .accessibilityIdentifier("detail_notes_field")
                    Button(viewModel.isSavingNotes ? "Menyimpan..." : "Simpan Catatan") {
                        guard let token = session.token else { return }
                        Task { await viewModel.saveNotes(token: token, appSession: session) }
                    }
                    .disabled(viewModel.isSavingNotes)
                    .accessibilityIdentifier("detail_save_notes_button")
                }

                Section("Feedback Kualitas Caption") {
                    Picker("Rating", selection: $viewModel.selectedRating) {
                        ForEach(CaptionFeedbackRating.allCases) { rating in
                            Text(rating.rawValue).tag(rating)
                        }
                    }
                    TextField("Apa yang perlu diperbaiki?", text: $viewModel.feedbackComment, axis: .vertical)
                        .accessibilityIdentifier("detail_feedback_comment_field")
                    Button(viewModel.isSubmittingFeedback ? "Mengirim..." : "Kirim Feedback") {
                        guard let token = session.token else { return }
                        Task { await viewModel.submitFeedback(token: token, appSession: session) }
                    }
                    .disabled(viewModel.isSubmittingFeedback)
                    .accessibilityIdentifier("detail_submit_feedback_button")
                }
            } else if viewModel.isLoading {
                ProgressView("Memuat detail...")
            } else {
                Text(viewModel.errorMessage ?? "Transkrip tidak ditemukan.")
                    .foregroundStyle(.secondary)
            }

            if let message = viewModel.message {
                Text(message)
                    .foregroundStyle(.green)
                    .accessibilityIdentifier("detail_success_message")
            }

            if let errorMessage = viewModel.errorMessage {
                VStack(alignment: .leading, spacing: 8) {
                    Text(errorMessage)
                        .foregroundStyle(.red)
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
                    }
                }
                .accessibilityIdentifier("detail_error_card")
            }
        }
        .navigationTitle("Detail Transkrip")
        .task {
            guard let token = session.token else { return }
            await viewModel.load(token: token, appSession: session)
        }
    }
}
