import Foundation
import Observation

@MainActor
@Observable
public final class GuardViewModel {
    // MARK: - Lots
    public var lots: [ParkingLot] = []
    public var selectedLotId: UUID = UUID()
    
    public var selectedLot: ParkingLot? {
        lots.first { $0.id == selectedLotId }
    }
    
    // MARK: - Scanner State
    public enum ScanStatus: Equatable {
        case idle
        case success(String)
        case rejected(String)
        case pending
    }
    
    public var scanStatus: ScanStatus = .idle
    public var lastScanDriver: String? = nil
    public var lastScanDirection: String? = nil
    public var lastScanTime: String? = nil
    public var isScanCooldown: Bool = false
    
    // MARK: - Violations
    public var violations: [ViolationEntry] = ViolationEntry.stubs
    public var isSubmittingViolation: Bool = false
    public var violationSubmitSuccess: Bool = false
    
    // MARK: - Init
    public init() {
        lots = Self.guardLots(from: ParkingLot.stubs)
        selectedLotId = lots.first?.id ?? UUID()
    }

    private static func guardLots(from stubs: [ParkingLot]) -> [ParkingLot] {
        let renamed = stubs.prefix(2).enumerated().map { index, lot in
            ParkingLot(
                id: lot.id,
                name: index == 0 ? "Parqueo Key" : "Parqueo Matías",
                capacityTotal: lot.capacityTotal,
                capacityUsed: lot.capacityUsed,
                active: lot.active
            )
        }
        return Array(renamed)
    }
    
    // MARK: - Scanner
    public func processScan(direction: ScanDirection) {
        guard !isScanCooldown else { return }
        isScanCooldown = true
        
        let timeFmt = DateFormatter()
        timeFmt.dateFormat = "hh:mm a"
        lastScanTime = timeFmt.string(from: Date())
        lastScanDirection = direction == .entry ? "ENTRADA" : "SALIDA"
        lastScanDriver = "Carlos Martínez"
        
        // Update lot occupancy optimistically
        if let idx = lots.firstIndex(where: { $0.id == selectedLotId }) {
            let lot = lots[idx]
            let newUsed: Int
            if direction == .entry {
                newUsed = min(lot.capacityUsed + 1, lot.capacityTotal)
            } else {
                newUsed = max(lot.capacityUsed - 1, 0)
            }
            lots[idx] = ParkingLot(
                id: lot.id,
                name: lot.name,
                capacityTotal: lot.capacityTotal,
                capacityUsed: newUsed,
                active: lot.active
            )
        }
        
        scanStatus = .success("Escaneo registrado correctamente")
        
        // Reset cooldown after 2 seconds
        Task {
            try? await Task.sleep(for: .seconds(2))
            self.isScanCooldown = false
        }
        
        // Reset status after 5 seconds
        Task {
            try? await Task.sleep(for: .seconds(5))
            self.scanStatus = .idle
        }
    }
    
    // MARK: - Violations
    public func submitViolation(_ entry: ViolationEntry) {
        isSubmittingViolation = true
        Task {
            try? await Task.sleep(for: .seconds(1))
            self.violations.insert(entry, at: 0)
            self.isSubmittingViolation = false
            self.violationSubmitSuccess = true
            try? await Task.sleep(for: .seconds(3))
            self.violationSubmitSuccess = false
        }
    }
}
