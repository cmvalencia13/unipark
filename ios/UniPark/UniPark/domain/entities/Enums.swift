import Foundation

public enum UserRole: String, Codable, Sendable {
    case driver
    case securityGuard
    case admin
    case superadmin
}

public enum ScanDirection: String, Codable, Sendable {
    case entry
    case exit
}

public enum ViolationStatus: String, Codable, Sendable {
    case pending
    case approved
    case dismissed
}
