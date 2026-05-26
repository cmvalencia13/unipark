import Foundation

public final class LotRepositoryImpl: LotRepository {
	private let client = NetworkClient.shared

	// Local fallback stub data
	private var fallbackLots: [ParkingLot] = [
		ParkingLot(name: "Lote A", capacityTotal: 50, capacityUsed: 32, active: true),
		ParkingLot(name: "Lote B", capacityTotal: 30, capacityUsed: 30, active: true),
		ParkingLot(name: "Lote C", capacityTotal: 80, capacityUsed: 10, active: true)
	]

	public init() {}

	public func fetchLots() async throws -> [ParkingLot] {
		do {
			let lots: [ParkingLot] = try await client.request(Endpoint.lots())
			return lots
		} catch {
			return fallbackLots
		}
	}

	public func fetchLot(id: UUID) async throws -> ParkingLot {
		// Try direct endpoint for specific lot, fallback to searching fetched list
		do {
			let endpoint = Endpoint(path: "lots/\(id.uuidString)", method: .GET)
			let lot: ParkingLot = try await client.request(endpoint)
			return lot
		} catch {
			let lots = try? await fetchLots()
			return lots?.first(where: { $0.id == id }) ?? fallbackLots[0]
		}
	}

	public func createLot(_ lot: ParkingLot) async throws -> ParkingLot {
		do {
			let endpoint = Endpoint(path: "lots", method: .POST, body: lot)
			let created: ParkingLot = try await client.request(endpoint)
			return created
		} catch {
			fallbackLots.append(lot)
			return lot
		}
	}

	public func updateLot(_ lot: ParkingLot) async throws -> ParkingLot {
		do {
			let endpoint = Endpoint(path: "lots/\(lot.id.uuidString)", method: .PATCH, body: lot)
			let updated: ParkingLot = try await client.request(endpoint)
			return updated
		} catch {
			if let idx = fallbackLots.firstIndex(where: { $0.id == lot.id }) {
				fallbackLots[idx] = lot
			} else {
				fallbackLots.append(lot)
			}
			return lot
		}
	}
}