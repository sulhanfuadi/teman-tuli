import SwiftUI
import UIKit

struct LiveCaptionView: View {
    @EnvironmentObject private var session: AppSession
    @StateObject private var viewModel: LiveCaptionViewModel

    init(apiClient: APIClient, runtimeConfig: UITestRuntimeConfig = .disabled) {
        _viewModel = StateObject(
            wrappedValue: LiveCaptionViewModel(
                apiClient: apiClient,
                speechService: SpeechCaptionService(runtimeConfig: runtimeConfig)
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        TextField(L10n.tr("live.session_title"), text: $viewModel.title)
                            .textFieldStyle(.roundedBorder)
                            .accessibilityIdentifier("session_title_field")
                        TextField(L10n.tr("live.class_name_optional"), text: $viewModel.className)
                            .textFieldStyle(.roundedBorder)
                            .accessibilityIdentifier("class_name_field")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.tr("live.title"))
                            .font(.headline)

                        Text(viewModel.speechService.liveText.isEmpty ? L10n.tr("live.placeholder") : viewModel.speechService.liveText)
                            .font(.system(size: viewModel.captionFontSize, weight: .semibold, design: .rounded))
                            .lineSpacing(10)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 220, alignment: .topLeading)
                            .padding()
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .accessibilityLabel(L10n.tr("live.accessibility.live_text"))
                            .accessibilityIdentifier("live_caption_text")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(L10n.tr("live.caption_size"))
                            Spacer()
                            Text("\(Int(viewModel.captionFontSize))")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $viewModel.captionFontSize, in: 28...44, step: 1)
                            .accessibilityIdentifier("caption_size_slider")
                    }

                    TextField(L10n.tr("live.personal_notes_optional"), text: $viewModel.notes, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("personal_notes_field")

                    HStack {
                        Button(viewModel.speechService.isRecording ? L10n.tr("live.recording") : L10n.tr("live.start")) {
                            Task { await viewModel.startCaptioning() }
                        }
                        .disabled(viewModel.speechService.isRecording)
                        .accessibilityIdentifier("start_caption_button")

                        Button(L10n.tr("live.stop")) { viewModel.stopCaptioning() }
                            .disabled(!viewModel.speechService.isRecording)
                            .accessibilityIdentifier("stop_caption_button")

                        Button(viewModel.isSaving ? L10n.tr("live.saving") : L10n.tr("live.save_private")) {
                            guard let token = session.token else { return }
                            Task { await viewModel.saveTranscript(token: token, session: session) }
                        }
                        .disabled(viewModel.isSaving || viewModel.speechService.isRecording)
                        .accessibilityIdentifier("save_private_button")
                    }
                    .buttonStyle(.borderedProminent)

                    privacyCard

                    if let message = viewModel.saveMessage {
                        Text(message)
                            .foregroundStyle(.green)
                            .accessibilityIdentifier("save_success_message")
                    }

                    if let message = viewModel.speechService.permissionMessage {
                        fallbackCard(message: message)
                    } else if let message = viewModel.errorMessage {
                        fallbackCard(message: message, requestReference: viewModel.errorRequestReference)
                    }
                }
                .padding()
            }
            .navigationTitle(L10n.tr("live.title"))
        }
    }

    private var privacyCard: some View {
        Label(L10n.tr("live.privacy_note"), systemImage: "lock.shield")
            .font(.callout)
            .foregroundStyle(.secondary)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.blue.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func fallbackCard(message: String, requestReference: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(message, systemImage: "exclamationmark.triangle")
                .foregroundStyle(.red)
            Text(L10n.tr("live.recovery_action"))
                .font(.caption)
                .foregroundStyle(.secondary)
            if let requestReference {
                HStack {
                    Text(String(format: L10n.tr("common.ref"), requestReference))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button(L10n.tr("common.copy_ref")) {
                        UIPasteboard.general.string = requestReference
                    }
                    .font(.caption)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityIdentifier("fallback_card")
    }
}
