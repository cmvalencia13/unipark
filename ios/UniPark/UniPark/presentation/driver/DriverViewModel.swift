import Foundation
import Observation

@MainActor
@Observable
public final class DriverViewModel {
    // MARK: - Lot Data
    public var lots: [ParkingLot] = []
    public var isLoading: Bool = false
    public var errorMessage: String? = nil

    // MARK: - Pass & User
    public var activePass: ActivePassDisplay? = ActivePassDisplay(
        lotName: "Parqueo Key",
        expiryDateString: "Dic 31, 2026 • Auto-Renew ON"
    )
    public var userName: String? = "María García"

    // MARK: - Parking Status (actualizado desde backend)
    public var isParked: Bool = false
    public var parkedLotName: String? = nil
    public var lastEntryScan: ScanResult? = nil
    public var lastScanResult: ScanResult? = nil

    // MARK: - Sticker Permit
    public var stickerPermit: StickerPermit? = nil

    // MARK: - QR Pass & Clock
    /// Payload firmado por el backend ("nonce:HMAC-base64").
    /// Se renueva automáticamente cada qrRotationSeconds consultando GET /v1/passes/active.
    public var passPayload: String = ""
    public var passCountdown: Int = 60
    public var currentTime: String = ""
    public var currentDate: String = ""

    // Tarea única de tick (reloj + countdown). Más fiable que Timer + RunLoop
    // con @Observable: cada segundo muta en MainActor y SwiftUI re-renderiza.
    // nonisolated(unsafe) para poder cancelarla desde deinit.
    private nonisolated(unsafe) var tickTask: Task<Void, Never>?

    // MARK: - Init
    public init() {
        loadData()
        updateClock()
        Task { await fetchActivePass() }
    }

    // MARK: - Timers
    public func startTimers() {
        stopTimers()
        passCountdown = FeatureFlags.qrRotationSeconds
        updateClock()

        tickTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self, !Task.isCancelled else { return }

                self.updateClock()
                self.passCountdown -= 1
                if self.passCountdown <= 0 {
                    self.passCountdown = FeatureFlags.qrRotationSeconds
                    await self.fetchActivePass()
                }
            }
        }
    }

    public func stopTimers() {
        tickTask?.cancel()
        tickTask = nil
    }

    deinit {
        tickTask?.cancel()
    }

    private func updateClock() {
        let now = Date()
        let timeFmt = DateFormatter()
        timeFmt.dateFormat = "hh:mm a"
        currentTime = timeFmt.string(from: now)

        let dateFmt = DateFormatter()
        dateFmt.locale = Locale(identifier: "es_ES")
        dateFmt.dateFormat = "EEEE, d 'de' MMMM"
        currentDate = dateFmt.string(from: now).capitalized
    }

    // MARK: - Sticker Permit
    public func saveStickerPermit(_ qrContent: String) {
        stickerPermit = StickerPermit(qrContent: qrContent, savedAt: Date())
    }

    // MARK: - QR Fetch
    public func fetchActivePass() async {
        do {
            let dto = try await PassAPIClient.shared.fetchActivePass()
            self.passPayload = dto.qrPayload
        } catch {
            // Si falla (sin backend, no conectado) dejamos el payload vacío o el anterior
            if passPayload.isEmpty {
                passPayload = "UNIPARK-NO-PASS"
            }
        }
    }

    // MARK: - Data Loading
    public func loadData() {
        if lots.isEmpty { lots = ParkingLot.stubs }
        Task {
            await refreshLots()
            await refreshParkingStatus()
        }
    }

    /// Refresca los lotes desde el backend. Llamar en onAppear de cualquier tab que muestre ocupación.
    public func refreshLots() async {
        if let remote = try? await LotAPIClient.shared.fetchAllLots(), !remote.isEmpty {
            self.lots = remote
        }
    }

    /// Refresca el estado de parking del conductor (dentro/fuera, en qué lote).
    public func refreshParkingStatus() async {
        guard let status = try? await PassAPIClient.shared.fetchMyStatus() else { return }
        self.isParked = status.isParked
        self.parkedLotName = status.lotName

        if let lotName = status.lotName, let dir = status.direction {
            let timeFmt = DateFormatter()
            timeFmt.locale = Locale(identifier: "es_ES")
            timeFmt.dateFormat = "hh:mm a"
            var timeStr = ""
            if let scannedAtStr = status.scannedAt,
               let date = ISO8601DateFormatter().date(from: scannedAtStr) {
                timeStr = timeFmt.string(from: date)
            }
            let scanDir: ScanResult.Direction = dir == "ENTRY" ? .entry : .exit
            let result = ScanResult(
                lotName: lotName,
                detail: dir == "ENTRY" ? "Entrada registrada" : "Salida registrada",
                timeString: timeStr,
                direction: scanDir
            )
            self.lastScanResult = result
            if dir == "ENTRY" { self.lastEntryScan = result }
        }
    }
}
