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
        lotName: "Commuter Zone A",
        expiryDateString: "Dic 31, 2026 • Auto-Renew ON"
    )
    public var userName: String? = "Carlos Test"

    // MARK: - Scans
    public var lastEntryScan: ScanResult? = nil
    public var lastScanResult: ScanResult? = nil

    // MARK: - Sticker Permit
    public var stickerPermit: StickerPermit? = nil

    // MARK: - QR Pass & Clock
    public var passPayload: String = "UNIPARK-DEV-STUB-PAYLOAD-001"
    public var passCountdown: Int = 60
    public var currentTime: String = ""
    public var currentDate: String = ""

    // Timer is nonisolated so deinit can safely invalidate it
    private nonisolated(unsafe) var clockTimer: Timer?

    // MARK: - Init
    public init() {
        loadData()
        updateClock()
    }

    // MARK: - Timers
    public func startTimers() {
        clockTimer?.invalidate()
        updateClock()
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.updateClock()
                self.passCountdown -= 1
                if self.passCountdown <= 0 {
                    self.passCountdown = 60
                    // Regenerate pass payload here when backend is ready
                }
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        clockTimer = timer
    }

    public func stopTimers() {
        clockTimer?.invalidate()
        clockTimer = nil
    }

    // nonisolated so deinit can call it without hopping to MainActor
    nonisolated public func invalidateTimers() {
        clockTimer?.invalidate()
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
        if lots.isEmpty {
            lots = ParkingLot.stubs
        }
    }
}
