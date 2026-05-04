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
                VStack(alignment: .leading, spacing: TTSpacing.lg) {
                    BrandWordmarkView(subtitle: L10n.tr("live.title"))

                    SectionCard {
                        VStack(alignment: .leading, spacing: TTSpacing.sm) {
                            TextField(L10n.tr("live.session_title"), text: $viewModel.title)
                                .textFieldStyle(.roundedBorder)
                                .accessibilityIdentifier("session_title_field")
                            TextField(L10n.tr("live.class_name_optional"), text: $viewModel.className)
                                .textFieldStyle(.roundedBorder)
                                .accessibilityIdentifier("class_name_field")
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: TTSpacing.sm) {
                            Text(L10n.tr("live.title"))
                                .font(TTTypography.headline)

                            Text(viewModel.speechService.liveText.isEmpty ? L10n.tr("live.placeholder") : viewModel.speechService.liveText)
                                .font(.system(size: viewModel.captionFontSize, weight: .semibold, design: .rounded))
                                .lineSpacing(10)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, minHeight: 240, alignment: .topLeading)
                                .padding(TTSpacing.md)
                                .background(TTColor.captionSurface)
                                .clipShape(RoundedRectangle(cornerRadius: TTCornerRadius.xl, style: .continuous))
                                .accessibilityLabel(L10n.tr("live.accessibility.live_text"))
                                .accessibilityIdentifier("live_caption_text")

                            HStack {
                                Text(L10n.tr("live.caption_size"))
                                Spacer()
                                Text("\(Int(viewModel.captionFontSize))")
                                    .foregroundStyle(.secondary)
                            }
                            Slider(value: $viewModel.captionFontSize, in: 28...44, step: 1)
                                .tint(TTColor.brand)
                                .accessibilityIdentifier("caption_size_slider")
                        }
                    }

                    SectionCard {
                        VStack(spacing: TTSpacing.sm) {
                            TextField(L10n.tr("live.personal_notes_optional"), text: $viewModel.notes, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .accessibilityIdentifier("personal_notes_field")

                            HStack(spacing: TTSpacing.sm) {
                                Button(viewModel.speechService.isRecording ? L10n.tr("live.recording") : L10n.tr("live.start")) {
                                    Task { await viewModel.startCaptioning() }
                                }
                                .buttonStyle(PrimaryActionButtonStyle())
                                .disabled(viewModel.speechService.isRecording)
                                .accessibilityIdentifier("start_caption_button")

                                Button(L10n.tr("live.stop")) { viewModel.stopCaptioning() }
                                    .buttonStyle(SecondaryActionButtonStyle())
                                    .disabled(!viewModel.speechService.isRecording)
                                    .accessibilityIdentifier("stop_caption_button")
                            }

                            Button(viewModel.isSaving ? L10n.tr("live.saving") : L10n.tr("live.save_private")) {
                                guard let token = session.token else { return }
                                Task { await viewModel.saveTranscript(token: token, session: session) }
                            }
                            .buttonStyle(PrimaryActionButtonStyle())
                            .disabled(viewModel.isSaving || viewModel.speechService.isRecording)
                            .accessibilityIdentifier("save_private_button")
                        }
                    }

                    SectionCard {
                        InlineNotice(message: L10n.tr("live.privacy_note"))
                    }

                    if let message = viewModel.saveMessage {
                        StatusCard(style: .success, message: message)
                            .accessibilityIdentifier("save_success_message")
                    }

                    if let message = viewModel.speechService.permissionMessage {
                        fallbackCard(message: message)
                    } else if let message = viewModel.errorMessage {
                        fallbackCard(message: message, requestReference: viewModel.errorRequestReference)
                    }
                }
                .padding(TTSpacing.lg)
            }
            .background(TTColor.background.ignoresSafeArea())
            .navigationTitle(L10n.tr("live.title"))
        }
    }

    private func fallbackCard(message: String, requestReference: String? = nil) -> some View {
        SectionCard {
            VStack(alignment: .leading, spacing: TTSpacing.sm) {
                StatusCard(style: .error, message: message, detail: L10n.tr("live.recovery_action"))
                if let requestReference {
                    HStack {
                        Text(String(format: L10n.tr("common.ref"), requestReference))
                            .font(TTTypography.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button(L10n.tr("common.copy_ref")) {
                            UIPasteboard.general.string = requestReference
                        }
                        .font(TTTypography.caption)
                    }
                }
            }
            .accessibilityIdentifier("fallback_card")
        }
    }
}
