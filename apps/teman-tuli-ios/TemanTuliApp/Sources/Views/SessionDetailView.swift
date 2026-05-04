import SwiftUI
import UIKit

struct SessionDetailView: View {
    @EnvironmentObject private var session: AppSession
    @StateObject private var viewModel: SessionDetailViewModel

    init(apiClient: APIClient, sessionId: String) {
        _viewModel = StateObject(wrappedValue: SessionDetailViewModel(apiClient: apiClient, sessionId: sessionId))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TTSpacing.lg) {
                if let transcript = viewModel.session {
                    SectionCard {
                        VStack(alignment: .leading, spacing: TTSpacing.sm) {
                            Text(L10n.tr("detail.section.info")).font(TTTypography.headline)
                            infoRow(L10n.tr("detail.label.title"), transcript.title)
                            infoRow(L10n.tr("detail.label.class"), transcript.className ?? "-")
                            infoRow(L10n.tr("detail.label.language"), transcript.languageCode)
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: TTSpacing.sm) {
                            Text(L10n.tr("detail.section.transcript")).font(TTTypography.headline)
                            Text(transcript.fullText)
                                .font(TTTypography.body)
                                .textSelection(.enabled)
                                .accessibilityIdentifier("detail_transcript_text")
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: TTSpacing.sm) {
                            Text(L10n.tr("detail.section.notes")).font(TTTypography.headline)
                            TextField(L10n.tr("detail.notes.placeholder"), text: $viewModel.notes, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .accessibilityIdentifier("detail_notes_field")
                            Button(viewModel.isSavingNotes ? L10n.tr("detail.notes.saving") : L10n.tr("detail.notes.save")) {
                                guard let token = session.token else { return }
                                Task { await viewModel.saveNotes(token: token, appSession: session) }
                            }
                            .buttonStyle(PrimaryActionButtonStyle())
                            .disabled(viewModel.isSavingNotes)
                            .accessibilityIdentifier("detail_save_notes_button")
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: TTSpacing.sm) {
                            Text(L10n.tr("detail.section.feedback")).font(TTTypography.headline)
                            Picker(L10n.tr("detail.feedback.rating"), selection: $viewModel.selectedRating) {
                                ForEach(CaptionFeedbackRating.allCases) { rating in
                                    Text(rating.displayLabel).tag(rating)
                                }
                            }
                            .pickerStyle(.segmented)

                            TextField(L10n.tr("detail.feedback.placeholder"), text: $viewModel.feedbackComment, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .accessibilityIdentifier("detail_feedback_comment_field")

                            Button(viewModel.isSubmittingFeedback ? L10n.tr("detail.feedback.submitting") : L10n.tr("detail.feedback.submit")) {
                                guard let token = session.token else { return }
                                Task { await viewModel.submitFeedback(token: token, appSession: session) }
                            }
                            .buttonStyle(SecondaryActionButtonStyle())
                            .disabled(viewModel.isSubmittingFeedback)
                            .accessibilityIdentifier("detail_submit_feedback_button")
                        }
                    }
                } else if viewModel.isLoading {
                    ProgressView(L10n.tr("detail.loading"))
                } else {
                    EmptyStateView(
                        title: L10n.tr("detail.not_found"),
                        subtitle: L10n.tr("detail.not_found_support"),
                        systemImage: "doc.text.magnifyingglass"
                    )
                }

                if let message = viewModel.message {
                    StatusCard(style: .success, message: message)
                        .accessibilityIdentifier("detail_success_message")
                }

                if let errorMessage = viewModel.errorMessage {
                    SectionCard {
                        VStack(alignment: .leading, spacing: TTSpacing.sm) {
                            StatusCard(style: .error, message: errorMessage)
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
                            }
                        }
                        .accessibilityIdentifier("detail_error_card")
                    }
                }
            }
            .padding(TTSpacing.lg)
        }
        .background(TTColor.background.ignoresSafeArea())
        .navigationTitle(L10n.tr("detail.nav_title"))
        .task {
            guard let token = session.token else { return }
            await viewModel.load(token: token, appSession: session)
        }
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(TTTypography.caption)
                .foregroundStyle(.secondary)
                .frame(width: 86, alignment: .leading)
            Text(value)
                .font(TTTypography.body)
            Spacer()
        }
    }
}
