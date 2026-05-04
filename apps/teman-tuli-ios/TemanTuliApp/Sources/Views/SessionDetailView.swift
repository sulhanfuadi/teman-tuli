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
                Section(L10n.tr("detail.section.info")) {
                    LabeledContent(L10n.tr("detail.label.title"), value: transcript.title)
                    LabeledContent(L10n.tr("detail.label.class"), value: transcript.className ?? "-")
                    LabeledContent(L10n.tr("detail.label.language"), value: transcript.languageCode)
                }

                Section(L10n.tr("detail.section.transcript")) {
                    Text(transcript.fullText)
                        .font(.body)
                        .textSelection(.enabled)
                        .accessibilityIdentifier("detail_transcript_text")
                }

                Section(L10n.tr("detail.section.notes")) {
                    TextField(L10n.tr("detail.notes.placeholder"), text: $viewModel.notes, axis: .vertical)
                        .accessibilityIdentifier("detail_notes_field")
                    Button(viewModel.isSavingNotes ? L10n.tr("detail.notes.saving") : L10n.tr("detail.notes.save")) {
                        guard let token = session.token else { return }
                        Task { await viewModel.saveNotes(token: token, appSession: session) }
                    }
                    .disabled(viewModel.isSavingNotes)
                    .accessibilityIdentifier("detail_save_notes_button")
                }

                Section(L10n.tr("detail.section.feedback")) {
                    Picker(L10n.tr("detail.feedback.rating"), selection: $viewModel.selectedRating) {
                        ForEach(CaptionFeedbackRating.allCases) { rating in
                            Text(rating.rawValue).tag(rating)
                        }
                    }
                    TextField(L10n.tr("detail.feedback.placeholder"), text: $viewModel.feedbackComment, axis: .vertical)
                        .accessibilityIdentifier("detail_feedback_comment_field")
                    Button(viewModel.isSubmittingFeedback ? L10n.tr("detail.feedback.submitting") : L10n.tr("detail.feedback.submit")) {
                        guard let token = session.token else { return }
                        Task { await viewModel.submitFeedback(token: token, appSession: session) }
                    }
                    .disabled(viewModel.isSubmittingFeedback)
                    .accessibilityIdentifier("detail_submit_feedback_button")
                }
            } else if viewModel.isLoading {
                ProgressView(L10n.tr("detail.loading"))
            } else {
                Text(viewModel.errorMessage ?? L10n.tr("detail.not_found"))
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
                            Text(String(format: L10n.tr("common.ref"), ref))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button(L10n.tr("common.copy_ref")) {
                                UIPasteboard.general.string = ref
                            }
                            .font(.caption)
                        }
                    }
                }
                .accessibilityIdentifier("detail_error_card")
            }
        }
        .navigationTitle(L10n.tr("detail.nav_title"))
        .task {
            guard let token = session.token else { return }
            await viewModel.load(token: token, appSession: session)
        }
    }
}
