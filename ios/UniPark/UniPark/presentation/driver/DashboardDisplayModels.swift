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
