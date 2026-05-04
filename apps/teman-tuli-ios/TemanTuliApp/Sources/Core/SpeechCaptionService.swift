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

    private let runtimeConfig: UITestRuntimeConfig
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var startedAt: Date?
    private var wasInterruptedWhileRecording: Bool = false

    var sessionStartedAt: Date? { startedAt }

    init(runtimeConfig: UITestRuntimeConfig = .disabled) {
        self.runtimeConfig = runtimeConfig
        registerLifecycleObservers()

        if runtimeConfig.isUITestMode, let mockTranscript = runtimeConfig.mockTranscript {
            setMockTranscript(mockTranscript)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func requestPermissions() async -> Bool {
        if runtimeConfig.isUITestMode { return true }

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
            permissionMessage = L10n.tr("speech.permission_required")
            return false
        }
        return true
    }

    func start() async {
        guard !isRecording else { return }

        if runtimeConfig.isUITestMode {
            permissionMessage = nil
            startedAt = Date()
            isRecording = true

            if let mockTranscript = runtimeConfig.mockTranscript {
                setMockTranscript(mockTranscript)
            }

            if let mockInterruption = runtimeConfig.mockInterruption {
                switch mockInterruption {
                case .background:
                    permissionMessage = L10n.tr("speech.background_interruption")
                case .audio:
                    permissionMessage = L10n.tr("speech.audio_interruption")
                }
                isRecording = false
            }
            return
        }

        guard await requestPermissions() else { return }
        guard recognizer?.isAvailable == true else {
            permissionMessage = L10n.tr("speech.unavailable")
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
            permissionMessage = L10n.tr("speech.mic_start_failed")
            teardownAudioPipeline()
            return
        }

        guard let request else {
            permissionMessage = L10n.tr("speech.request_setup_failed")
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
                    self.permissionMessage = L10n.tr("speech.caption_stopped")
                    self.stop()
                }
            }
        }
    }

    func stop() {
        if runtimeConfig.isUITestMode {
            isRecording = false
            return
        }

        teardownAudioPipeline()
        isRecording = false
    }

    private func setMockTranscript(_ text: String) {
        liveText = text
        if segments.isEmpty {
            segments = [TranscriptSegment(id: nil, text: text, startMs: 0, endMs: nil)]
        }
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
                permissionMessage = L10n.tr("speech.audio_interruption")
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
            permissionMessage = L10n.tr("speech.background_interruption")
            stop()
        }
    }

    @objc private func handleDidBecomeActive() {
        if wasInterruptedWhileRecording {
            wasInterruptedWhileRecording = false
        }
    }
}
