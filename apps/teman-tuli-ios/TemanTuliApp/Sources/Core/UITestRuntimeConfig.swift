import Foundation

enum MockInterruptionType: String {
    case background
    case audio
}

struct UITestRuntimeConfig {
    let isUITestMode: Bool
    let mockAuthenticated: Bool
    let mockTranscript: String?
    let mockInterruption: MockInterruptionType?
    let mockAPIBaseURL: String?

    static let disabled = UITestRuntimeConfig(
        isUITestMode: false,
        mockAuthenticated: false,
        mockTranscript: nil,
        mockInterruption: nil,
        mockAPIBaseURL: nil
    )

    static var current: UITestRuntimeConfig {
        let arguments = ProcessInfo.processInfo.arguments

        let isUITestMode = arguments.contains("--uitest-mode")
        let mockAuthenticated = arguments.contains("--mock-authenticated")
        let mockTranscript = value(forPrefix: "--mock-transcript=", in: arguments)
            .map(decodeArgumentValue)
        let mockInterruption = value(forPrefix: "--mock-interruption=", in: arguments)
            .flatMap { MockInterruptionType(rawValue: $0.lowercased()) }
        let mockAPIBaseURL = value(forPrefix: "--mock-api-base-url=", in: arguments)
            .map(decodeArgumentValue)

        return UITestRuntimeConfig(
            isUITestMode: isUITestMode,
            mockAuthenticated: mockAuthenticated,
            mockTranscript: mockTranscript,
            mockInterruption: mockInterruption,
            mockAPIBaseURL: mockAPIBaseURL
        )
    }

    private static func value(forPrefix prefix: String, in arguments: [String]) -> String? {
        arguments.first(where: { $0.hasPrefix(prefix) })?.replacingOccurrences(of: prefix, with: "")
    }

    private static func decodeArgumentValue(_ raw: String) -> String {
        raw
            .replacingOccurrences(of: "__SPACE__", with: " ")
            .removingPercentEncoding ?? raw
    }
}
