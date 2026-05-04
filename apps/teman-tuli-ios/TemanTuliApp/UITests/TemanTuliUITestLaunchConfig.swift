import Foundation

enum UITestInterruption: String {
    case background
    case audio
}

struct TemanTuliUITestLaunchConfig {
    var authenticated: Bool = true
    var transcript: String = "Simulator test transcript"
    var interruption: UITestInterruption?
    var mockAPIBaseURL: String?

    func launchArguments() -> [String] {
        var args = ["--uitest-mode"]

        if authenticated {
            args.append("--mock-authenticated")
        }

        let encodedTranscript = transcript.replacingOccurrences(of: " ", with: "__SPACE__")
        args.append("--mock-transcript=\(encodedTranscript)")

        if let interruption {
            args.append("--mock-interruption=\(interruption.rawValue)")
        }

        if let mockAPIBaseURL {
            let encodedURL = mockAPIBaseURL.replacingOccurrences(of: " ", with: "__SPACE__")
            args.append("--mock-api-base-url=\(encodedURL)")
        }

        return args
    }
}
