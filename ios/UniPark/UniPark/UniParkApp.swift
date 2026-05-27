import SwiftUI
import SwiftData
import Network

@main
struct UniParkApp: App {
    private let networkSyncManager = NetworkSyncManager()

    init() {
        // UniParkNavBarAppearance.apply() — disabled: UIAppearance in init causes issues on iOS 26
        networkSyncManager.start()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        // .modelContainer(for: PendingScan.self) — disabled temporarily, re-enable when SwiftData schema is stable
    }
}

private final class NetworkSyncManager {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.unipark.network.monitor")
    private var started = false

    func start() {
        guard !started else { return }
        started = true

        monitor.pathUpdateHandler = { path in
            guard path.status == .satisfied else { return }
            Task {
                try? await ScanRepositoryImpl().syncPendingScans()
            }
        }

        monitor.start(queue: queue)

        Task {
            if monitor.currentPath.status == .satisfied {
                try? await ScanRepositoryImpl().syncPendingScans()
            }
        }
    }

    deinit {
        monitor.cancel()
    }
}
