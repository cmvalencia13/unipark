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
        case verifying                          // loading — esperando resultado
        case accepted(VerificationOutcome)      // verde — acceso autorizado
        case rejected(VerificationOutcome)      // rojo — razón específica
    }

    public var scanStatus: ScanStatus = .idle
    public var lastScanDirection: String? = nil
    public var lastScanTime: String? = nil
    public var isScanCooldown: Bool = false

    // MARK: - Violations
    public var violations: [ViolationEntry] = ViolationEntry.stubs
    public var isSubmittingViolation: Bool = false
    public var violationSubmitSuccess: Bool = false

    // MARK: - Init
    public init() {
        lots = Array(ParkingLot.stubs.prefix(2))
        selectedLotId = lots.first?.id ?? UUID()
        // Carga lotes reales del backend en background
        Task {
            if let remote = try? await LotAPIClient.shared.fetchAllLots(), !remote.isEmpty {
                self.lots = remote
                self.selectedLotId = remote.first?.id ?? self.selectedLotId
            }
        }
    }

    // MARK: - Scanner

    /// Simula escanear un QR con el payload dado en la dirección indicada.
    /// Para pruebas, usar los prefijos definidos en MockPassVerificationService:
    ///   "UNIPARK-..."  → válido
    ///   "EXPIRED-..."  → expirado
    ///   "USED-..."     → ya usado
    ///   "WRONG-LOT-..."→ lote incorrecto
    ///   "REVOKED-..."  → revocado
    ///   cualquier otro → firma inválida
    public func processScan(direction: ScanDirection, payload: String = "UNIPARK-DEMO") {
        guard !isScanCooldown else { return }
        isScanCooldown = true

        let timeFmt = DateFormatter()
        timeFmt.dateFormat = "hh:mm a"
        lastScanTime = timeFmt.string(from: Date())
        lastScanDirection = direction == .entry ? "ENTRADA" : "SALIDA"
        scanStatus = .verifying

        Task {
            let outcome = await MockPassVerificationService.shared.verify(
                payload: payload,
                selectedLotName: selectedLot?.name ?? ""
            )

            if outcome.isValid {
                // Actualizar ocupación optimistamente solo si es válido
                updateOccupancy(direction: direction)
                scanStatus = .accepted(outcome)
            } else {
                scanStatus = .rejected(outcome)
            }

            // Reset cooldown tras 2s
            try? await Task.sleep(for: .seconds(2))
            isScanCooldown = false

            // Reset estado tras 6s
            try? await Task.sleep(for: .seconds(4))
            if case .accepted = scanStatus { scanStatus = .idle }
            if case .rejected = scanStatus { scanStatus = .idle }
        }
    }

    private func updateOccupancy(direction: ScanDirection) {
        guard let idx = lots.firstIndex(where: { $0.id == selectedLotId }) else { return }
        let lot = lots[idx]
        let newUsed = direction == .entry
            ? min(lot.capacityUsed + 1, lot.capacityTotal)
            : max(lot.capacityUsed - 1, 0)
        lots[idx] = ParkingLot(
            id: lot.id,
            name: lot.name,
            capacityTotal: lot.capacityTotal,
            capacityUsed: newUsed,
            active: lot.active
        )
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
