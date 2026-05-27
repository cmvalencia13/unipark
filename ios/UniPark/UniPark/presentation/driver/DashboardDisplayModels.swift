import Foundation

/// Lightweight display model for the active pass card.
public struct ActivePassDisplay {
    public let lotName: String
    public let expiryDateString: String
    public init(lotName: String, expiryDateString: String) {
        self.lotName = lotName
        self.expiryDateString = expiryDateString
    }
}

/// Lightweight display model for the current vehicle card.
public struct VehicleDisplay {
    public let plate: String
    public let details: String
    public init(plate: String, details: String) {
        self.plate = plate
        self.details = details
    }
}

/// Scan result display model for home tab and access QR.
public struct ScanResult: Identifiable {
    public enum Direction { case entry, exit }
    public let id = UUID()
    public let lotName: String
    public let detail: String
    public let timeString: String
    public let direction: Direction
    
    public init(lotName: String, detail: String, timeString: String, direction: Direction) {
        self.lotName = lotName
        self.detail = detail
        self.timeString = timeString
        self.direction = direction
    }
}

/// Sticker permit display model for physical permit tab.
public struct StickerPermit: Identifiable {
    public let id = UUID()
    public let qrContent: String
    public let savedAt: Date
    
    public init(qrContent: String, savedAt: Date) {
        self.qrContent = qrContent
        self.savedAt = savedAt
    }
}

/// Violation entry for guard violations tab.
public struct ViolationEntry: Identifiable {
    public enum ViolationStatus { case pending, approved, dismissed }
    public enum ViolationReason: String, CaseIterable {
        case badParking = "Vehículo mal parqueado"
        case noScan = "No escaneó al entrar/salir"
        case wrongLot = "Estacionado en lote incorrecto"
        case hitAndRun = "Choque no reportado"
        case passAbuse = "Uso indebido del pase"
    }
    
    public let id: UUID
    public let plate: String
    public let lotName: String
    public let reason: ViolationReason
    public let createdAt: Date
    public var status: ViolationStatus
    public var hasPhoto: Bool
    
    public init(id: UUID = UUID(), plate: String, lotName: String,
                reason: ViolationReason, createdAt: Date = Date(),
                status: ViolationStatus = .pending, hasPhoto: Bool = false) {
        self.id = id
        self.plate = plate
        self.lotName = lotName
        self.reason = reason
        self.createdAt = createdAt
        self.status = status
        self.hasPhoto = hasPhoto
    }
    
    public static let stubs: [ViolationEntry] = [
        ViolationEntry(plate: "ABC-1234", lotName: "Lote A",
                       reason: .badParking, status: .pending),
        ViolationEntry(plate: "XYZ-9988", lotName: "Lote B",
                       reason: .wrongLot, status: .approved),
    ]
}
