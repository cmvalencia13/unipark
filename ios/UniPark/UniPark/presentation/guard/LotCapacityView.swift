import SwiftUI

public struct LotCapacityView: View {
	@State private var lots: [ParkingLot] = []
	@State private var refreshTimer: Timer?
	
	private let manageLotUseCase = AppDIContainer.shared.manageLotUseCase
	private let columns = [
		GridItem(.flexible(), spacing: 16),
		GridItem(.flexible(), spacing: 16)
	]
	
	public init() {}
	
	public var body: some View {
		NavigationStack {
			ScrollView {
				LazyVGrid(columns: columns, spacing: 16) {
					ForEach(lots, id: \.id) { lot in
						lotCell(for: lot)
					}
				}
				.padding()
			}
			.navigationTitle("Capacidad de Lotes")
			.navigationBarTitleDisplayMode(.inline)
		}
		.task {
			await loadLots()
			startAutoRefresh()
		}
		.onDisappear {
			stopAutoRefresh()
		}
	}
	
	private func lotCell(for lot: ParkingLot) -> some View {
		ZStack(alignment: .topTrailing) {
			// Background with color based on occupancy
			RoundedRectangle(cornerRadius: 12)
				.fill(backgroundColorForOccupancy(lot.occupancyPercentage))
			
			VStack(alignment: .leading, spacing: 12) {
				Text(lot.name)
					.font(.headline)
					.foregroundStyle(.primary)
				
				VStack(alignment: .leading, spacing: 4) {
					Text("\(lot.capacityUsed)/\(lot.capacityTotal)")
						.font(.system(.title2, design: .rounded))
						.fontWeight(.bold)
						.foregroundStyle(.primary)
					
					Text("Espacios disponibles")
						.font(.caption)
						.foregroundStyle(.secondary)
				}
				
				// Capacity bar
				GeometryReader { geometry in
					ZStack(alignment: .leading) {
						RoundedRectangle(cornerRadius: 4)
							.fill(Color.white.opacity(0.3))
						
						RoundedRectangle(cornerRadius: 4)
							.fill(
								Color(
									hue: occupancyHue(lot.occupancyPercentage),
									saturation: 0.8,
									brightness: 0.9
								)
							)
							.frame(width: geometry.size.width * lot.occupancyPercentage)
					}
				}
				.frame(height: 8)
				
				Text("\(Int(lot.occupancyPercentage * 100))%")
					.font(.caption2)
					.foregroundStyle(.secondary)
			}
			.padding()
			.frame(maxWidth: .infinity, alignment: .leading)
			
			// LLENO badge
			if lot.isFull {
				VStack {
					HStack {
						Spacer()
						
						VStack(spacing: 4) {
							Text("LLENO")
								.font(.caption2)
								.fontWeight(.bold)
								.foregroundStyle(.white)
						}
						.frame(maxWidth: .infinity)
						.padding(.vertical, 6)
						.background(Color.red)
						.cornerRadius(6)
						.padding(8)
					}
				}
			}
		}
		.frame(minHeight: 160)
	}
	
	private func backgroundColorForOccupancy(_ occupancy: Double) -> Color {
		switch occupancy {
		case 0..<0.7:
			return Color.green.opacity(0.15)
		case 0.7..<0.9:
			return Color.orange.opacity(0.15)
		default:
			return Color.red.opacity(0.15)
		}
	}
	
	private func occupancyHue(_ occupancy: Double) -> Double {
		switch occupancy {
		case 0..<0.7:
			return 0.35 // Green
		case 0.7..<0.9:
			return 0.08 // Orange
		default:
			return 0 // Red
		}
	}
	
	private func loadLots() async {
		do {
			lots = try await manageLotUseCase.fetchAll()
		} catch {
			print("Error loading lots: \(error)")
		}
	}
	
	private func startAutoRefresh() {
		refreshTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
			Task {
				await loadLots()
			}
		}
	}
	
	private func stopAutoRefresh() {
		refreshTimer?.invalidate()
		refreshTimer = nil
	}
}

#Preview {
	LotCapacityView()
}