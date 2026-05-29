import Foundation

public final class TokenStorage {
    public static let shared = TokenStorage()

    private let defaults = UserDefaults.standard
    private let accessKey = "unipark_access_token"
    private let refreshKey = "unipark_refresh_token"
    private let idKey = "unipark_id_token"

    // TODO: Migrate storage to Keychain for production.

    private init() {}

    public var accessToken: String? {
        get { defaults.string(forKey: accessKey) }
        set {
            if let value = newValue {
                defaults.set(value, forKey: accessKey)
            } else {
                defaults.removeObject(forKey: accessKey)
            }
        }
    }

    public var refreshToken: String? {
        get { defaults.string(forKey: refreshKey) }
        set {
            if let value = newValue {
                defaults.set(value, forKey: refreshKey)
            } else {
                defaults.removeObject(forKey: refreshKey)
            }
        }
    }

    public var idToken: String? {
        get { defaults.string(forKey: idKey) }
        set {
            if let value = newValue {
                defaults.set(value, forKey: idKey)
            } else {
                defaults.removeObject(forKey: idKey)
            }
        }
    }

    public func save(accessToken: String, refreshToken: String) {
        defaults.set(accessToken, forKey: accessKey)
        defaults.set(refreshToken, forKey: refreshKey)
    }

    public func save(accessToken: String, refreshToken: String, idToken: String?) {
        defaults.set(accessToken, forKey: accessKey)
        defaults.set(refreshToken, forKey: refreshKey)
        if let idToken { defaults.set(idToken, forKey: idKey) }
    }

    public func clear() {
        defaults.removeObject(forKey: accessKey)
        defaults.removeObject(forKey: refreshKey)
        defaults.removeObject(forKey: idKey)
    }
}
