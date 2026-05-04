import Foundation

@MainActor
final class LiveCaptionViewModel: ObservableObject {
    @Published var title: String = L10n.tr("live.default_title")
    @Published var className: String = ""
    @Published var notes: String = ""
    @Published var saveMessage: String?
    @Published var errorMessage: String?
    @Published var errorRequestReference: String?
    @Published var isSaving: Bool = false
    @Published var captionFontSize: Double = 34

    let speechService: SpeechCaptionService
    private let apiClient: APIClient

    init(apiClient: APIClient, speechService: SpeechCaptionService? = nil) {
        self.apiClient = apiClient
        self.speechService = speechService ?? SpeechCaptionService(runtimeConfig: .disabled)
    }

    func startCaptioning() async {
        saveMessage = nil
        errorMessage = nil
        errorRequestReference = nil
        await speechService.start()
    }

    func stopCaptioning() {
        speechService.stop()
    }

    func saveTranscript(token: String, session: AppSession) async {
        guard !isSaving else { return }

        guard !speechService.liveText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = L10n.tr("live.error.empty_transcript")
            errorRequestReference = nil
            return
        }

        isSaving = true
        saveMessage = nil
        errorMessage = nil
        errorRequestReference = nil
        defer { isSaving = false }

        let startedAt = speechService.sessionStartedAt ?? Date()
        let endedAt = Date()
        let payload = NewTranscriptSession(
            title: title.isEmpty ? L10n.tr("live.default_title") : title,
            className: className.isEmpty ? nil : className,
            languageCode: "en-US",
            fullText: speechService.liveText,
            notes: notes.isEmpty ? nil : notes,
            startedAt: startedAt,
            endedAt: endedAt,
            segments: speechService.segments.isEmpty
                ? [TranscriptSegment(id: nil, text: speechService.liveText, startMs: 0, endMs: nil)]
                : speechService.segments
        )

        do {
            _ = try await apiClient.createSession(token: token, payload: payload)
            saveMessage = L10n.tr("live.save_success")
        } catch let error as APIError {
            if error == .unauthorized {
                session.expireAuth()
                errorMessage = nil
                errorRequestReference = nil
                return
            }
            let mapped = mapError(error)
            errorMessage = mapped.message
            errorRequestReference = mapped.requestReference
        } catch {
            errorMessage = L10n.tr("live.save_failed")
            errorRequestReference = nil
        }
    }

    private func mapError(_ error: APIError) -> APIErrorPresentation {
        APIErrorMessageFormatter.presentation(
            for: error,
            networkMessage: L10n.tr("live.network_failed"),
            fallbackMessage: L10n.tr("live.save_fallback")
        )
    }
}
