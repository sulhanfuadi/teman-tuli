import Foundation

@MainActor
final class LiveCaptionViewModel: ObservableObject {
    @Published var title: String = "Catatan Kelas"
    @Published var className: String = ""
    @Published var notes: String = ""
    @Published var saveMessage: String?
    @Published var errorMessage: String?
    @Published var isSaving: Bool = false

    let speechService: SpeechCaptionService
    private let apiClient: APIClient

    init(apiClient: APIClient, speechService: SpeechCaptionService = SpeechCaptionService()) {
        self.apiClient = apiClient
        self.speechService = speechService
    }

    func startCaptioning() async {
        saveMessage = nil
        errorMessage = nil
        await speechService.start()
    }

    func stopCaptioning() {
        speechService.stop()
    }

    func saveTranscript(token: String) async {
        guard !speechService.liveText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Belum ada transkrip untuk disimpan."
            return
        }

        isSaving = true
        saveMessage = nil
        errorMessage = nil
        defer { isSaving = false }

        let startedAt = speechService.sessionStartedAt ?? Date()
        let endedAt = Date()
        let payload = NewTranscriptSession(
            title: title.isEmpty ? "Catatan Kelas" : title,
            className: className.isEmpty ? nil : className,
            languageCode: "id-ID",
            fullText: speechService.liveText,
            notes: notes.isEmpty ? nil : notes,
            startedAt: startedAt,
            endedAt: endedAt,
            segments: speechService.segments.isEmpty ? [TranscriptSegment(id: nil, text: speechService.liveText, startMs: 0, endMs: nil)] : speechService.segments
        )

        do {
            _ = try await apiClient.createSession(token: token, payload: payload)
            saveMessage = "Transkrip disimpan secara privat."
        } catch {
            errorMessage = "Gagal menyimpan transkrip. Coba lagi setelah koneksi stabil."
        }
    }
}
