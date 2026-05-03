import AVFoundation
import Foundation
import Speech
import UIKit

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
    private var wasInterruptedWhileRecording: Bool = false

    var sessionStartedAt: Date? { startedAt }

    init() {
        registerLifecycleObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

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

        permissionMessage = nil
        liveText = ""
        segments = []
        startedAt = Date()
        wasInterruptedWhileRecording = false

        let newRequest = SFSpeechAudioBufferRecognitionRequest()
        newRequest.shouldReportPartialResults = true
        request = newRequest

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
            teardownAudioPipeline()
            return
        }

        guard let request else {
            permissionMessage = "Gagal menyiapkan speech request."
            teardownAudioPipeline()
            return
        }

        recognitionTask = recognizer?.recognitionTask(with: request) { [weak self] result, error in
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

                if error != nil {
                    self.permissionMessage = "Caption berhenti. Silakan tekan Mulai Caption untuk melanjutkan."
                    self.stop()
                }
            }
        }
    }

    func stop() {
        teardownAudioPipeline()
        isRecording = false
    }

    private func teardownAudioPipeline() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        recognitionTask?.cancel()
        request = nil
        recognitionTask = nil
    }

    private func registerLifecycleObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioInterruption),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc private func handleAudioInterruption(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let interruptionType = AVAudioSession.InterruptionType(rawValue: typeValue)
        else {
            return
        }

        switch interruptionType {
        case .began:
            if isRecording {
                wasInterruptedWhileRecording = true
                permissionMessage = "Rekaman berhenti karena interupsi audio (misalnya panggilan masuk)."
                stop()
            }
        case .ended:
            break
        @unknown default:
            break
        }
    }

    @objc private func handleWillResignActive() {
        if isRecording {
            wasInterruptedWhileRecording = true
            permissionMessage = "Rekaman dihentikan saat aplikasi ke background. Tekan Mulai Caption untuk lanjut."
            stop()
        }
    }

    @objc private func handleDidBecomeActive() {
        if wasInterruptedWhileRecording {
            wasInterruptedWhileRecording = false
        }
    }
}
