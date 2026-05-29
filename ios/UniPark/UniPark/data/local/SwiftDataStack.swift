import Foundation
import SwiftData

public final class SwiftDataStack {
	public static let shared = SwiftDataStack()

	public let container: ModelContainer
	public let context: ModelContext

	private init() {
		do {
			let schema = Schema([PendingScan.self])
			let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
			let modelContainer = try ModelContainer(for: schema, configurations: [configuration])
			self.container = modelContainer
			self.context = modelContainer.mainContext
		} catch {
			fatalError("Unable to initialize SwiftData container: \(error)")
		}
	}

	public func savePendingScan(_ scan: PendingScan) throws {
		context.insert(scan)
		try context.save()
	}

	public func fetchPendingScans() throws -> [PendingScan] {
		let descriptor = FetchDescriptor<PendingScan>(
			predicate: #Predicate { !$0.synced },
			sortBy: [SortDescriptor(\PendingScan.scannedAt, order: .forward)]
		)
		return try context.fetch(descriptor)
	}

	public func markSynced(_ scan: PendingScan) throws {
		scan.synced = true
		try context.save()
	}

	public func deleteSynced() throws {
		let cutoff = Date().addingTimeInterval(-24 * 60 * 60)
		let descriptor = FetchDescriptor<PendingScan>(
			predicate: #Predicate { $0.synced && $0.scannedAt < cutoff }
		)
		let oldSynced = try context.fetch(descriptor)
		for item in oldSynced {
			context.delete(item)
		}
		if !oldSynced.isEmpty {
			try context.save()
		}
	}
}
