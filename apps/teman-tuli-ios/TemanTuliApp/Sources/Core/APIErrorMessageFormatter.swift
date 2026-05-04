import Foundation

enum APIErrorMessageFormatter {
    static func friendlyMessage(
        for error: APIError,
        networkMessage: String,
        fallbackMessage: String
    ) -> String {
        switch error {
        case .networkUnavailable:
            return networkMessage
        case .invalidURL:
            return "Alamat server tidak valid. Periksa pengaturan endpoint API."
        case .decodingError:
            return "Respons server tidak dapat diproses. Coba lagi."
        case .unauthorized:
            return "Sesi berakhir. Silakan login kembali."
        case .serverError(let statusCode, let code, let serverMessage, let requestId):
            let baseMessage = friendlyServerMessage(
                statusCode: statusCode,
                code: code,
                serverMessage: serverMessage,
                fallbackMessage: fallbackMessage
            )
            return appendRequestReference(baseMessage, requestId: requestId)
        }
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

    private static func appendRequestReference(_ message: String, requestId: String?) -> String {
        guard let requestId, !requestId.isEmpty else { return message }
        let shortRef = String(requestId.prefix(8))
        return "\(message) (Ref: \(shortRef))"
    }
}
