import SwiftUI

public struct DriverDashboardView: View {
	@State private var viewModel = DriverDashboardViewModel()
	@State private var showingErrorAlert = false

	public init() {}

	public var body: some View {
		ZStack {
			Color.upBackground
				.ignoresSafeArea()

			ScrollView(showsIndicators: false) {
				VStack(alignment: .leading, spacing: 12) {
					header
					activePermitCard
					currentVehicleCard
					campusTrendsCard
					systemAlertsCard
				}
				.padding(.horizontal, 16)
				.padding(.vertical, 20)
			}

			if viewModel.isLoading {
				ProgressView()
					.progressViewStyle(CircularProgressViewStyle(tint: .upPrimary))
					.padding()
					.background(Color.upSurfaceHighest.opacity(0.6))
					.clipShape(RoundedRectangle(cornerRadius: 16))
			}
		}
		.task {
			await viewModel.loadData()
		}
		.onChange(of: viewModel.errorMessage) { _, newValue in
			showingErrorAlert = newValue != nil
		}
		.alert("No fue posible cargar los datos", isPresented: $showingErrorAlert) {
			Button("Cerrar", role: .cancel) {
				viewModel.errorMessage = nil
			}
		} message: {
			Text(viewModel.errorMessage ?? "Ocurrió un error inesperado.")
		}
	}

	// MARK: - Header
	private var header: some View {
		HStack(spacing: 12) {
			Image(systemName: "person.crop.circle.fill")
				.font(.title)
				.foregroundStyle(Color.upPrimary)
				.padding(8)
				.background(Color.upSurfaceHighest)
				.clipShape(Circle())

			Text("UniPark")
				.font(.title2.weight(.bold))
				.foregroundStyle(Color.upPrimary)

			Spacer()

			Button(action: {}) {
				Image(systemName: "bell.fill")
					.font(.title3)
					.foregroundStyle(Color.upPrimaryText)
					.padding(10)
					.background(Color.upSurfaceHighest)
					.clipShape(Circle())
			}
		}
		.foregroundStyle(Color.upTextPrimary)
		.padding(.horizontal, 4)
	}

	// MARK: - Active Permit Card
	private var activePermitCard: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("ACTIVE PERMIT")
				.font(.system(size: 11, weight: .semibold))
				.foregroundColor(.upPrimary)
				.kerning(1.2)

			HStack(alignment: .top) {
				VStack(alignment: .leading, spacing: 8) {
					Text(viewModel.activePass?.lotName ?? "Commuter Zone A")
						.font(.title.bold())
						.foregroundStyle(Color.upTextPrimary)

					Text("Expiry: \(viewModel.activePass?.expiryDateString ?? "Jun 30, 2026")")
						.font(.subheadline)
						.foregroundStyle(Color.upTextSecondary)
				}

				Spacer()

				VStack(alignment: .trailing, spacing: 8) {
					HStack(spacing: 6) {
						GlowingDot(color: .upSecondary, size: 6)
						Text("Status Valid")
							.font(.subheadline.weight(.semibold))
							.foregroundStyle(Color.upSurfaceLowest)
					}
					.padding(.horizontal, 10)
					.padding(.vertical, 6)
					.background(Color.upSecondary)
					.clipShape(Capsule())

					Button(action: {}) {
						HStack(spacing: 6) {
							Text("Manage Permit")
								.font(.subheadline.weight(.semibold))
							Image(systemName: "chevron.right")
						}
						.foregroundStyle(Color.upPrimaryText)
					}
				}
			}
		}
		.padding(16)
		.glassCard(cornerRadius: 16, glowColor: .upPrimary)
	}

	// MARK: - Current Vehicle Card
	private var currentVehicleCard: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("CURRENT VEHICLE")
				.font(.system(size: 11, weight: .semibold))
				.foregroundColor(.upPrimary)
				.kerning(1.2)

			HStack {
				VStack(alignment: .leading, spacing: 6) {
					Text(viewModel.currentVehicle?.plate ?? "Lot B")
						.font(.title3.weight(.bold))
						.foregroundStyle(Color.upTextPrimary)
					Text(viewModel.currentVehicle?.details ?? "Spot 42 • Level 2")
						.font(.subheadline)
						.foregroundStyle(Color.upTextSecondary)
				}
				Spacer()
			}

			Button(action: {}) {
				Label("Find My Car", systemImage: "car.fill")
					.font(.subheadline.weight(.semibold))
					.frame(maxWidth: .infinity)
					.padding(.vertical, 12)
					.background(Color.upSecondary)
					.foregroundColor(Color.upSurfaceLowest)
					.clipShape(RoundedRectangle(cornerRadius: 12))
			}
		}
		.padding(16)
		.glassCard(cornerRadius: 16, glowColor: .clear)
	}

	// MARK: - Campus Trends Card
	private var campusTrendsCard: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack {
				Text("CAMPUS TRENDS")
					.font(.system(size: 11, weight: .semibold))
					.foregroundColor(.upPrimary)
					.kerning(1.2)
				Spacer()
				Text("⋯")
					.foregroundStyle(Color.upTextSecondary)
			}

			ForEach(Array(viewModel.lots.prefix(2).enumerated()), id: \.offset) { _, lot in
				VStack(alignment: .leading, spacing: 6) {
					HStack {
						Text(lot.name)
							.font(.subheadline)
							.foregroundStyle(Color.upTextPrimary)
						Spacer()
						Text(String(format: "%.0f%% Full", lot.occupancyPercentage * 100))
							.font(.subheadline.weight(.semibold))
							.foregroundStyle(Color.upPrimary)
					}

					GeometryReader { proxy in
						ZStack(alignment: .leading) {
							RoundedRectangle(cornerRadius: 4)
								.fill(Color.upSurfaceHighest)
								.frame(height: 8)
							RoundedRectangle(cornerRadius: 4)
								.fill(Color.upSecondary)
								.frame(width: max(0, proxy.size.width * CGFloat(lot.occupancyPercentage)), height: 8)
						}
					}
					.frame(height: 8)
				}
			}
		}
		.padding(16)
		.glassCard(cornerRadius: 16, glowColor: .clear)
	}

	// MARK: - System Alerts Card
	private var systemAlertsCard: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack(alignment: .top, spacing: 12) {
				Image(systemName: "exclamationmark.triangle.fill")
					.font(.title2)
					.foregroundStyle(Color.orange)
					.padding(8)
					.background(Color.upSurfaceHighest)
					.clipShape(Circle())

				VStack(alignment: .leading, spacing: 6) {
					Text("SYSTEM ALERTS")
						.font(.system(size: 11, weight: .semibold))
						.foregroundColor(.upPrimary)
						.kerning(1.2)

					Text("Maintenance scheduled in Lot C. Some spots will be closed.")
						.font(.subheadline)
						.foregroundStyle(Color.upTextSecondary)

					Text("4 HOURS AGO")
						.font(.caption2.weight(.semibold))
						.foregroundStyle(Color.upTextSecondary)
						.kerning(0.8)
				}
			}
		}
		.padding(16)
		.glassCard(cornerRadius: 16, glowColor: .clear)
	}
}

// MARK: - Parking Lot Card (reusable)
struct ParkingLotCard: View {
	let lot: ParkingLot

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack {
				Text(lot.name)
					.font(.headline)
					.foregroundStyle(Color.upTextPrimary)
				Spacer()
				Circle()
					.fill(statusColor)
					.frame(width: 10, height: 10)
					.shadow(color: statusColor.opacity(0.8), radius: 4)
			}

			Text("\(lot.capacityUsed) / \(lot.capacityTotal) spots")
				.font(.subheadline)
				.foregroundStyle(Color.upTextSecondary)

			ProgressView(value: lot.occupancyPercentage)
				.tint(statusColor)
		}
		.padding()
		.frame(width: 220)
		.glassCard(cornerRadius: 16, glowColor: statusColor)
	}

	private var statusColor: Color {
		let o = lot.occupancyPercentage
		if o < 0.7 { return .upSecondary }
		else if o < 0.9 { return .orange }
		else { return .upError }
	}
}
