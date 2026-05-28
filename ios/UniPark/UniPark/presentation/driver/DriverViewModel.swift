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

    // MARK: - Scans
    // Demo scenario: conductor entró hace 12 minutos a Parqueo Key
    public var lastEntryScan: ScanResult? = ScanResult(
        lotName: "Parqueo Key",
        detail: "Acceso autorizado • Spot A-14",
        timeString: "Hace 12 min",
        direction: .entry
    )
    public var lastScanResult: ScanResult? = ScanResult(
        lotName: "Parqueo Key",
        detail: "Acceso autorizado • Spot A-14",
        timeString: "Hace 12 min",
        direction: .entry
    )

    // MARK: - Sticker Permit
    public var stickerPermit: StickerPermit? = nil

    // MARK: - QR Pass & Clock
    public var passPayload: String = "UNIPARK-\(UUID().uuidString)"
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
                    // Phase 1 — UUID temporal para que el QR rote visualmente.
                    // Phase 2 (post-backend) — reemplazar con JWT firmado de
                    // PassRepository.generateAccessToken() y validar server-side.
                    self.passPayload = "UNIPARK-\(UUID().uuidString)"
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

    // MARK: - Data Loading
    public func loadData() {
        // Carga inicial con stubs para que la UI no quede vacía
        if lots.isEmpty { lots = ParkingLot.stubs }
        // Luego intenta el backend real (GET /v1/lots es público — no requiere auth)
        Task {
            if let remote = try? await LotAPIClient.shared.fetchAllLots(), !remote.isEmpty {
                self.lots = remote
            }
        }
    }
}
