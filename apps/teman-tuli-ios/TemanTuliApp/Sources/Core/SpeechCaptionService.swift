import AVFoundation
import Foundation
import Speech

@MainActor
final class SpeechCaptionService: ObservableObject {
    @Published var liveText: String = ""
    @Published var isRecording: Bool = false
    @Published var permissionMessage: String?
    @Published var segments: [TranscriptSegment] = []

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "id-ID"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var startedAt: Date?

    var sessionStartedAt: Date? { startedAt }

    func requestPermissions() async -> Bool {
        let speechAuthorized = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }

        let micAuthorized = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                continuation.resume(returning: allowed)
            }
        }

        if !speechAuthorized || !micAuthorized {
            permissionMessage = "Aktifkan izin mikrofon dan speech recognition untuk memakai live caption."
            return false
        }
        return true
    }

    func start() async {
        guard !isRecording else { return }
        guard await requestPermissions() else { return }
        guard recognizer?.isAvailable == true else {
            permissionMessage = "Speech recognition Bahasa Indonesia sedang tidak tersedia."
            return
        }

        liveText = ""
        segments = []
        startedAt = Date()
        request = SFSpeechAudioBufferRecognitionRequest()
        request?.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            permissionMessage = "Gagal memulai mikrofon."
            return
        }

        recognitionTask = recognizer?.recognitionTask(with: request!) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                if let result {
                    self.liveText = result.bestTranscription.formattedString
                    self.segments = result.bestTranscription.segments.map { segment in
                        TranscriptSegment(
                            id: nil,
                            text: segment.substring,
                            startMs: Int(segment.timestamp * 1000),
                            endMs: Int((segment.timestamp + segment.duration) * 1000)
                        )
                    }
                }
                if error != nil { self.stop() }
            }
        }
    }

    func stop() {
        guard isRecording else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        recognitionTask?.cancel()
        request = nil
        recognitionTask = nil
        isRecording = false
    }
}
