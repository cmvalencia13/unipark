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

    // Timers are nonisolated(unsafe) so deinit can safely invalidate them
    private nonisolated(unsafe) var clockTimer: Timer?
    private nonisolated(unsafe) var countdownTimer: Timer?

    // MARK: - Init
    public init() {
        loadData()
        updateClock()
        Task { await fetchActivePass() }
    }

    // MARK: - Timers
    public func startTimers() {
        // Clock: updates currentTime / currentDate every second
        clockTimer?.invalidate()
        updateClock()
        let cTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor [weak self] in
                self?.updateClock()
            }
        }
        RunLoop.main.add(cTimer, forMode: .common)
        clockTimer = cTimer

        // Countdown: ticks every second, regenerates QR payload at 0
        countdownTimer?.invalidate()
        passCountdown = FeatureFlags.qrRotationSeconds
        let qTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.passCountdown -= 1
                if self.passCountdown <= 0 {
                    self.passCountdown = FeatureFlags.qrRotationSeconds
                    await self.fetchActivePass()
                }
            }
        }
        RunLoop.main.add(qTimer, forMode: .common)
        countdownTimer = qTimer
    }

    public func stopTimers() {
        clockTimer?.invalidate()
        clockTimer = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
    }

    // nonisolated so deinit can call it without hopping to MainActor
    nonisolated public func invalidateTimers() {
        clockTimer?.invalidate()
        countdownTimer?.invalidate()
    }

    deinit {
        invalidateTimers()
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
