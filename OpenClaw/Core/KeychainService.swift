import Foundation
import Security

enum KeychainError: LocalizedError {
    case unhandledError(status: OSStatus)

    var errorDescription: String? {
        switch self {
        case .unhandledError(let status):
            return "Keychain error (OSStatus \(status))."
        }
    }
}

/// Account-scoped Keychain operations. Each account stores its token under a unique key.
enum KeychainService: Sendable {
    private static let service = "co.uk.appwebdev.openclaw"
    private static let legacyAccount = "gateway-token"

    // MARK: - Per-account tokens

    static func saveToken(_ token: String, forAccount accountId: String) throws {
        let data = Data(token.utf8)
        let account = "account-\(accountId)"
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword, kSecAttrService: service, kSecAttrAccount: account]
        let attributes: [CFString: Any] = [kSecValueData: data]

        var status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var addQuery = query
            addQuery[kSecValueData] = data
            status = SecItemAdd(addQuery as CFDictionary, nil)
        }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }

    static func readToken(forAccount accountId: String) -> String? {
        let account = "account-\(accountId)"
        return readItem(account: account)
    }

    static func deleteToken(forAccount accountId: String) throws {
        let account = "account-\(accountId)"
        try deleteItem(account: account)
    }

    // MARK: - Legacy (single-account migration)

    static func readLegacyToken() -> String? {
        readItem(account: legacyAccount)
    }

    static func deleteLegacyToken() throws {
        try deleteItem(account: legacyAccount)
    }

    // MARK: - Helpers

    private static func readItem(account: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func deleteItem(account: String) throws {
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword, kSecAttrService: service, kSecAttrAccount: account]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
}
