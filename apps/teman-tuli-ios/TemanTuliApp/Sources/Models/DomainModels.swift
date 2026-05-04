import Foundation

enum CaptionFeedbackRating: String, Codable, CaseIterable, Identifiable {
    case poor = "POOR"
    case okay = "OKAY"
    case good = "GOOD"
    case excellent = "EXCELLENT"

    var id: String { rawValue }

    var displayLabel: String {
        switch self {
        case .poor: return "Poor"
        case .okay: return "Okay"
        case .good: return "Good"
        case .excellent: return "Excellent"
        }
    }
}

struct TranscriptSegment: Codable, Identifiable, Equatable {
    var id: String?
    let text: String
    let startMs: Int
    let endMs: Int?
}

struct TranscriptSession: Codable, Identifiable, Equatable {
    let id: String
    var title: String
    var className: String?
    var languageCode: String
    var fullText: String
    var notes: String?
    var startedAt: Date
    var endedAt: Date
    var createdAt: Date?
    var updatedAt: Date?
    var segments: [TranscriptSegment]?
}

struct NewTranscriptSession: Codable, Equatable {
    let title: String
    let className: String?
    let languageCode: String
    let fullText: String
    let notes: String?
    let startedAt: Date
    let endedAt: Date
    let segments: [TranscriptSegment]
}

struct AuthUser: Codable, Equatable {
    let id: String
    let name: String
    let email: String
    let goal: String?
}
