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
    public var backendErrorMessage: String? = nil

    // MARK: - Violations
    public var violations: [ViolationEntry] = ViolationEntry.stubs
    public var isSubmittingViolation: Bool = false
    public var violationSubmitSuccess: Bool = false

    // MARK: - Init
    public init() {
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
    public nonisolated static let demoPayload = "demo-nonce-unipark-2024:c1g/f+9vlffqM6biUXEUHEqH87X7NBUz2wFoNa2L15I="

    public func processScan(direction: ScanDirection, payload: String = GuardViewModel.demoPayload) {
        guard !isScanCooldown, let lot = selectedLot else { return }
        isScanCooldown = true

        let timeFmt = DateFormatter()
        timeFmt.dateFormat = "hh:mm a"
        lastScanTime = timeFmt.string(from: Date())
        lastScanDirection = direction == .entry ? "ENTRADA" : "SALIDA"
        scanStatus = .verifying

        Task {
            backendErrorMessage = nil
            let result = await tryRecordScanInBackend(payload: payload, lotId: lot.id, direction: direction)

            switch result {
            case .success:
                await refreshLots()
                scanStatus = .accepted(.valid(driverName: "Conductor Autorizado", lotId: lot.id))
            case .failure(let msg):
                // Mostrar el mensaje del backend directamente (ej: "ya tiene entrada registrada")
                backendErrorMessage = msg
                scanStatus = .rejected(.invalid(reason: msg))
            }

            try? await Task.sleep(for: .seconds(2))
            isScanCooldown = false
            try? await Task.sleep(for: .seconds(4))
            backendErrorMessage = nil
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
    ) async -> Result<Void, String> {
        do {
            _ = try await ScanAPIClient.shared.recordScan(
                qrPayload: payload,
                lotId: lotId,
                direction: direction
            )
            return .success(())
        } catch let NetworkError.clientError(code) where code == 400 {
            // Mensaje de error del backend (ej: entrada doble, QR inválido)
            return .failure(ScanAPIClient.lastErrorMessage ?? "QR inválido o acceso denegado.")
        } catch {
            return .failure("Sin conexión con el servidor.")
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
