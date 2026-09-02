import Foundation
import Security

/// Persistência nativa da sessão para App Intents.
/// O token fica no Keychain; metadados não sensíveis vão para o App Group.
final class DinixSessionStore: @unchecked Sendable {
    static let shared = DinixSessionStore()

    static let appGroupId = "group.com.net.convertix.dinix"
    static let keychainService = "com.net.convertix.dinix.siri"
    static let flutterSecureService = "com.net.convertix.dinix"
    static let tokenAccount = "auth_token"

    private let defaults: UserDefaults
    private let lock = NSLock()

    private init() {
        defaults = UserDefaults(suiteName: Self.appGroupId) ?? .standard
    }

    var isAuthenticated: Bool {
        guard let token = accessToken, !token.isEmpty else { return false }
        return !isSessionDayExpired
    }

    var accessToken: String? {
        lock.lock()
        defer { lock.unlock() }
        if let stored = readKeychain(service: Self.keychainService, account: Self.tokenAccount),
           !stored.isEmpty {
            return stored
        }
        if let flutter = readKeychain(service: Self.flutterSecureService, account: Self.tokenAccount),
           !flutter.isEmpty {
            writeKeychain(service: Self.keychainService, account: Self.tokenAccount, value: flutter)
            return flutter
        }
        return nil
    }

    var apiBaseURL: String {
        defaults.string(forKey: Keys.apiBaseURL) ?? "https://dinix.api.convertix.net.br"
    }

    var clientId: String {
        defaults.string(forKey: Keys.clientId) ?? "dinix-mobile"
    }

    var clientSecret: String {
        defaults.string(forKey: Keys.clientSecret) ?? "dinix-mobile-client"
    }

    var appVersion: String {
        defaults.string(forKey: Keys.appVersion) ?? "1.0.0"
    }

    var deviceId: String {
        if let existing = defaults.string(forKey: Keys.deviceId), !existing.isEmpty {
            return existing
        }
        return "siri-unknown"
    }

    var userId: String? {
        defaults.string(forKey: Keys.userId)
    }

    var biometriaHabilitada: Bool {
        defaults.bool(forKey: Keys.biometriaHabilitada)
    }

    var isSessionDayExpired: Bool {
        guard let saved = defaults.string(forKey: Keys.authDay), !saved.isEmpty else {
            return accessToken == nil
        }
        return saved != Self.todayKey()
    }

    func saveSession(
        token: String,
        userId: String?,
        authDay: String?,
        deviceId: String?,
        apiBaseURL: String?,
        clientId: String?,
        clientSecret: String?,
        appVersion: String?,
        biometriaHabilitada: Bool?
    ) {
        lock.lock()
        defer { lock.unlock() }
        writeKeychain(service: Self.keychainService, account: Self.tokenAccount, value: token)
        if let userId { defaults.set(userId, forKey: Keys.userId) }
        defaults.set(authDay ?? Self.todayKey(), forKey: Keys.authDay)
        if let deviceId, !deviceId.isEmpty { defaults.set(deviceId, forKey: Keys.deviceId) }
        if let apiBaseURL, !apiBaseURL.isEmpty { defaults.set(apiBaseURL, forKey: Keys.apiBaseURL) }
        if let clientId, !clientId.isEmpty { defaults.set(clientId, forKey: Keys.clientId) }
        if let clientSecret, !clientSecret.isEmpty { defaults.set(clientSecret, forKey: Keys.clientSecret) }
        if let appVersion, !appVersion.isEmpty { defaults.set(appVersion, forKey: Keys.appVersion) }
        if let biometriaHabilitada { defaults.set(biometriaHabilitada, forKey: Keys.biometriaHabilitada) }
    }

    func clearSession() {
        lock.lock()
        defer { lock.unlock() }
        deleteKeychain(service: Self.keychainService, account: Self.tokenAccount)
        defaults.removeObject(forKey: Keys.userId)
        defaults.removeObject(forKey: Keys.authDay)
        defaults.removeObject(forKey: Keys.onScreenType)
        defaults.removeObject(forKey: Keys.onScreenId)
        defaults.removeObject(forKey: Keys.onScreenTitle)
        defaults.removeObject(forKey: Keys.pendingRoute)
        defaults.removeObject(forKey: Keys.pendingEntityId)
    }

    func setOnScreenEntity(type: String?, id: String?, title: String?) {
        if let type, let id, !type.isEmpty, !id.isEmpty {
            defaults.set(type, forKey: Keys.onScreenType)
            defaults.set(id, forKey: Keys.onScreenId)
            defaults.set(title, forKey: Keys.onScreenTitle)
        } else {
            defaults.removeObject(forKey: Keys.onScreenType)
            defaults.removeObject(forKey: Keys.onScreenId)
            defaults.removeObject(forKey: Keys.onScreenTitle)
        }
    }

    func onScreenEntity() -> (type: String, id: String, title: String?)? {
        guard let type = defaults.string(forKey: Keys.onScreenType),
              let id = defaults.string(forKey: Keys.onScreenId),
              !type.isEmpty, !id.isEmpty else { return nil }
        return (type, id, defaults.string(forKey: Keys.onScreenTitle))
    }

    func setPendingRoute(route: String?, entityId: String?) {
        if let route, !route.isEmpty {
            defaults.set(route, forKey: Keys.pendingRoute)
            defaults.set(entityId, forKey: Keys.pendingEntityId)
        } else {
            defaults.removeObject(forKey: Keys.pendingRoute)
            defaults.removeObject(forKey: Keys.pendingEntityId)
        }
    }

    func consumePendingRoute() -> [String: String] {
        guard let route = defaults.string(forKey: Keys.pendingRoute), !route.isEmpty else {
            return [:]
        }
        var payload = ["route": route]
        if let id = defaults.string(forKey: Keys.pendingEntityId), !id.isEmpty {
            payload["id"] = id
        }
        defaults.removeObject(forKey: Keys.pendingRoute)
        defaults.removeObject(forKey: Keys.pendingEntityId)
        return payload
    }

    func peekPendingRoute() -> [String: String] {
        guard let route = defaults.string(forKey: Keys.pendingRoute), !route.isEmpty else {
            return [:]
        }
        var payload = ["route": route]
        if let id = defaults.string(forKey: Keys.pendingEntityId), !id.isEmpty {
            payload["id"] = id
        }
        return payload
    }

    static func todayKey(now: Date = Date(), calendar: Calendar = .current) -> String {
        DinixDateRange.isoDate(now, calendar: calendar)
    }

    private enum Keys {
        static let apiBaseURL = "siri_api_base_url"
        static let clientId = "siri_client_id"
        static let clientSecret = "siri_client_secret"
        static let appVersion = "siri_app_version"
        static let deviceId = "siri_device_id"
        static let userId = "siri_user_id"
        static let authDay = "siri_auth_day"
        static let biometriaHabilitada = "siri_biometria_habilitada"
        static let onScreenType = "siri_onscreen_type"
        static let onScreenId = "siri_onscreen_id"
        static let onScreenTitle = "siri_onscreen_title"
        static let pendingRoute = "siri_pending_route"
        static let pendingEntityId = "siri_pending_entity_id"
    }

    private func readKeychain(service: String, account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    @discardableResult
    private func writeKeychain(service: String, account: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(query as CFDictionary)
        var add = query
        add[kSecValueData as String] = data
        add[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        return SecItemAdd(add as CFDictionary, nil) == errSecSuccess
    }

    private func deleteKeychain(service: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
