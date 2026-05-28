import Foundation

public final class TokenStorage {
    public static let shared = TokenStorage()

    private let defaults = UserDefaults.standard
    private let accessKey = "unipark_access_token"
    private let refreshKey = "unipark_refresh_token"

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

    public func save(accessToken: String, refreshToken: String) {
        defaults.set(accessToken, forKey: accessKey)
        defaults.set(refreshToken, forKey: refreshKey)
    }

    public func clear() {
        defaults.removeObject(forKey: accessKey)
        defaults.removeObject(forKey: refreshKey)
    }
}
