import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()

    private init() {}

    enum KeychainKey: String {
        case openAIKey = "com.rapturegauge.openai.key"
        case newsAPIKey = "com.rapturegauge.newsapi.key"
        case claudeAPIKey = "com.rapturegauge.claude.key"
    }

    func save(key: String, for keychainKey: KeychainKey) -> Bool {
        let data = key.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey.rawValue,
            kSecValueData as String: data
        ]

        // Delete any existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    func retrieve(for keychainKey: KeychainKey) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess,
           let data = dataTypeRef as? Data,
           let key = String(data: data, encoding: .utf8) {
            return key
        }

        return nil
    }

    func delete(for keychainKey: KeychainKey) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey.rawValue
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }

    func hasAPIKeys() -> Bool {
        return retrieve(for: .openAIKey) != nil && retrieve(for: .newsAPIKey) != nil
    }
}