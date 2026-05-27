import SwiftUI
import SwiftData
import Network

@main
struct UniParkApp: App {
    private let networkSyncManager = NetworkSyncManager()
    private let container: ModelContainer = Self.makeContainer()

    init() {
        networkSyncManager.start()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }

    /// Creates the SwiftData container. If the on-disk store is corrupted or
    /// has a schema conflict it deletes it and starts fresh (offline queue is
    /// non-critical — scans pending sync are lost, but no data breach occurs).
    private static func makeContainer() -> ModelContainer {
        let schema = Schema([PendingScan.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Store corrupted or schema mismatch — wipe and recreate
            print("[UniPark] SwiftData store error, resetting: \(error)")
            let url = config.url
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.removeItem(at: url.deletingLastPathComponent()
                .appendingPathComponent(url.deletingPathExtension().lastPathComponent + ".store-wal"))
            try? FileManager.default.removeItem(at: url.deletingLastPathComponent()
                .appendingPathComponent(url.deletingPathExtension().lastPathComponent + ".store-shm"))
            // Fallback to in-memory so app always launches
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: [fallback])
        }
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
