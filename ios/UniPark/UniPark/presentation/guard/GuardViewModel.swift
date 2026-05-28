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
        case verifying
        case accepted(VerificationOutcome)
        case rejected(VerificationOutcome)
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
        // Inyectar token mock para que el backend JWT mock acepte las requests
        // Phase 2: reemplazar por el JWT real de Keycloak
        if TokenStorage.shared.accessToken == nil {
            TokenStorage.shared.accessToken = "dev-mock-token-guard"
        }

        lots = Array(ParkingLot.stubs.prefix(2))
        selectedLotId = lots.first?.id ?? UUID()
        Task { await refreshLots() }
    }

    // MARK: - Lots

    private func refreshLots() async {
        if let remote = try? await LotAPIClient.shared.fetchAllLots(), !remote.isEmpty {
            // Preservar selectedLotId si el lote sigue existiendo
            let currentId = selectedLotId
            lots = remote
            if remote.contains(where: { $0.id == currentId }) {
                selectedLotId = currentId
            } else {
                selectedLotId = remote.first?.id ?? currentId
            }
        }
    }

    // MARK: - Scanner

    /// Procesa un escaneo de QR.
    /// Con backend activo: llama POST /v1/scans y actualiza ocupación en Postgres.
    /// Fallback: actualización local optimista si el backend no responde.
    ///
    /// Payload de prueba (devMode):
    ///   "UNIPARK-DEMO"   → válido (mock local)
    ///   "EXPIRED-test"   → expirado
    ///   "USED-test"      → ya usado
    ///   "WRONG-LOT-test" → lote incorrecto
    ///   "REVOKED-test"   → revocado
    // Payload demo: nonce real + HMAC-SHA256 firmado con el secret del backend.
    // Phase 2: el conductor genera este payload desde POST /v1/passes → iOS lo muestra como QR.
    public static let demoPayload = "demo-nonce-unipark-2024:c1g/f+9vlffqM6biUXEUHEqH87X7NBUz2wFoNa2L15I="

    public func processScan(direction: ScanDirection, payload: String = GuardViewModel.demoPayload) {
        guard !isScanCooldown, let lot = selectedLot else { return }
        isScanCooldown = true

        let timeFmt = DateFormatter()
        timeFmt.dateFormat = "hh:mm a"
        lastScanTime = timeFmt.string(from: Date())
        lastScanDirection = direction == .entry ? "ENTRADA" : "SALIDA"
        scanStatus = .verifying

        Task {
            // 1. Intentar POST /v1/scans en el backend real
            let backendSuccess = await tryRecordScanInBackend(
                payload: payload,
                lotId: lot.id,
                direction: direction
            )

            if backendSuccess {
                // 2a. Backend registró el scan — refrescar lotes para tener
                //     capacityUsed actualizado desde Postgres
                await refreshLots()
                scanStatus = .accepted(.valid(driverName: "Conductor Autorizado", lotId: lot.id))
            } else {
                // 2b. Backend no disponible o payload inválido — usar mock local
                let outcome = await MockPassVerificationService.shared.verify(
                    payload: payload,
                    selectedLotName: lot.name
                )
                if outcome.isValid {
                    updateOccupancyLocally(direction: direction)
                    scanStatus = .accepted(outcome)
                } else {
                    scanStatus = .rejected(outcome)
                }
            }

            // Reset cooldown tras 2s
            try? await Task.sleep(for: .seconds(2))
            isScanCooldown = false

            // Reset estado tras 4s más
            try? await Task.sleep(for: .seconds(4))
            if case .accepted = scanStatus { scanStatus = .idle }
            if case .rejected = scanStatus { scanStatus = .idle }
        }
    }

    /// Intenta registrar el scan en el backend.
    /// Retorna true si el backend aceptó el scan, false si falló o no está disponible.
    private func tryRecordScanInBackend(
        payload: String,
        lotId: UUID,
        direction: ScanDirection
    ) async -> Bool {
        do {
            _ = try await ScanAPIClient.shared.recordScan(
                qrPayload: payload,
                lotId: lotId,
                direction: direction
            )
            return true
        } catch {
            // Backend no disponible, QR inválido o error de red → fallback a mock
            return false
        }
    }

    /// Actualización local optimista cuando el backend no está disponible.
    private func updateOccupancyLocally(direction: ScanDirection) {
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
