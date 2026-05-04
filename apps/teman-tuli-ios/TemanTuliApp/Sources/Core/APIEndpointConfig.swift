import Foundation

enum APIEndpointConfig {
    static let storageKey = "temantuli.api.base_url"
    static let defaultBaseURLString = "http://localhost:3000/api/v1"

    static func currentBaseURLString(store: UserDefaults = .standard) -> String {
        let stored = (store.string(forKey: storageKey) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return stored.isEmpty ? defaultBaseURLString : stored
    }

    static func currentBaseURL(store: UserDefaults = .standard) -> URL {
        let value = currentBaseURLString(store: store)
        return URL(string: value) ?? URL(string: defaultBaseURLString)!
    }

    @discardableResult
    static func saveBaseURL(_ rawValue: String, store: UserDefaults = .standard) -> Bool {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isValidBaseURL(trimmed) else { return false }
        store.set(trimmed, forKey: storageKey)
        return true
    }

    static func isValidBaseURL(_ value: String) -> Bool {
        guard
            let url = URL(string: value),
            let scheme = url.scheme?.lowercased(),
            ["http", "https"].contains(scheme),
            url.host != nil
        else {
            return false
        }
        return true
    }
}
