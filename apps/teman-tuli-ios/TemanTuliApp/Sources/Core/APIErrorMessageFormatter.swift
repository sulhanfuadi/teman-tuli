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
                message: "Alamat server tidak valid. Periksa pengaturan endpoint API.",
                requestReference: nil
            )
        case .decodingError:
            return APIErrorPresentation(
                message: "Respons server tidak dapat diproses. Coba lagi.",
                requestReference: nil
            )
        case .unauthorized:
            return APIErrorPresentation(message: "Sesi berakhir. Silakan login kembali.", requestReference: nil)
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
            return "Terlalu banyak permintaan. Coba lagi beberapa saat."
        case "PAYLOAD_TOO_LARGE":
            return "Data terlalu besar untuk diproses. Ringkas isi lalu coba lagi."
        case "VALIDATION_ERROR":
            return "Input belum valid. Periksa kembali data yang diisi."
        case "NOT_FOUND":
            return "Data yang diminta tidak ditemukan."
        case "CONFLICT":
            return "Terjadi konflik data. Muat ulang lalu coba lagi."
        case "INTERNAL_ERROR":
            return "Server sedang bermasalah. Coba lagi beberapa saat."
        default:
            if statusCode == 409 {
                return "Terjadi konflik data. Muat ulang lalu coba lagi."
            }
            if let serverMessage, !serverMessage.isEmpty {
                return "Permintaan gagal: \(serverMessage)"
            }
            return fallbackMessage
        }
    }

    private static func shortRef(_ requestId: String?) -> String? {
        guard let requestId, !requestId.isEmpty else { return nil }
        return String(requestId.prefix(8))
    }
}
