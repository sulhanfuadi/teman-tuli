import Foundation

struct APIErrorPresentation: Equatable {
    let message: String
    let requestReference: String?
}

enum APIErrorMessageFormatter {
    static func presentation(
        for error: APIError,
        networkMessage: String,
        fallbackMessage: String
    ) -> APIErrorPresentation {
        switch error {
        case .networkUnavailable:
            return APIErrorPresentation(message: networkMessage, requestReference: nil)
        case .invalidURL:
            return APIErrorPresentation(
                message: L10n.tr("error.invalid_url"),
                requestReference: nil
            )
        case .decodingError:
            return APIErrorPresentation(
                message: L10n.tr("error.decoding"),
                requestReference: nil
            )
        case .unauthorized:
            return APIErrorPresentation(message: L10n.tr("error.unauthorized"), requestReference: nil)
        case .serverError(let statusCode, let code, let serverMessage, let requestId):
            return APIErrorPresentation(
                message: friendlyServerMessage(
                    statusCode: statusCode,
                    code: code,
                    serverMessage: serverMessage,
                    fallbackMessage: fallbackMessage
                ),
                requestReference: shortRef(requestId)
            )
        }
    }

    static func friendlyMessage(
        for error: APIError,
        networkMessage: String,
        fallbackMessage: String
    ) -> String {
        presentation(for: error, networkMessage: networkMessage, fallbackMessage: fallbackMessage).message
    }

    private static func friendlyServerMessage(
        statusCode: Int,
        code: String?,
        serverMessage: String?,
        fallbackMessage: String
    ) -> String {
        switch code?.uppercased() {
        case "RATE_LIMITED":
            return L10n.tr("error.rate_limited")
        case "PAYLOAD_TOO_LARGE":
            return L10n.tr("error.payload_too_large")
        case "VALIDATION_ERROR":
            return L10n.tr("error.validation")
        case "NOT_FOUND":
            return L10n.tr("error.not_found")
        case "CONFLICT":
            return L10n.tr("error.conflict")
        case "INTERNAL_ERROR":
            return L10n.tr("error.internal")
        default:
            if statusCode == 409 {
                return L10n.tr("error.conflict")
            }
            if let serverMessage, !serverMessage.isEmpty {
                return String(format: L10n.tr("error.request_failed"), serverMessage)
            }
            return fallbackMessage
        }
    }

    private static func shortRef(_ requestId: String?) -> String? {
        guard let requestId, !requestId.isEmpty else { return nil }
        return String(requestId.prefix(8))
    }
}
