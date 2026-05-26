import SwiftUI

public struct DriverDashboardView: View {
	@State private var viewModel = DriverDashboardViewModel()
	@State private var showingErrorAlert = false

	public init() {}

	public var body: some View {
		NavigationStack {
			ZStack {
				Color(.systemBackground)
					.ignoresSafeArea()

				ScrollView {
					VStack(alignment: .leading, spacing: 20) {
						headerSection
						lotsCarouselSection
						digitalPassSection
						lotsListSection
					}
					.padding()
				}

				if viewModel.isLoading {
					ProgressView()
						.padding()
						.background(.thinMaterial)
						.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
				}
			}
			.navigationTitle("UniPark")
			.navigationBarTitleDisplayMode(.inline)
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
	}

	// MARK: - Sections

	private var headerSection: some View {
		HStack(spacing: 12) {
			Image(systemName: "building.2.fill")
				.font(.title2)
				.foregroundStyle(Color.accentColor)
				.padding(12)
				.background(.thinMaterial)
				.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

			VStack(alignment: .leading, spacing: 4) {
				Text("Bienvenido, \(viewModel.user?.fullName ?? "Usuario")")
					.font(.title2.bold())
				Text("Tu estado de estacionamiento universitario")
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}

			Spacer()
		}
		.padding()
		.background(.thinMaterial)
		.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
	}

	private var lotsCarouselSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Lotes")
				.font(.headline)

			ScrollView(.horizontal, showsIndicators: false) {
				HStack(spacing: 12) {
					ForEach(viewModel.lots) { lot in
						ParkingLotCard(lot: lot)
					}
				}
				.padding(.vertical, 2)
			}
		}
	}

	private var digitalPassSection: some View {
		NavigationLink {
			DigitalPassView()
		} label: {
			HStack(spacing: 12) {
				Image(systemName: "qrcode.viewfinder")
					.font(.title2)
				Text("Ver mi Pase Digital")
					.font(.headline)
				Spacer()
				Image(systemName: "chevron.right")
					.font(.subheadline.weight(.semibold))
			}
			.foregroundStyle(.white)
			.padding()
			.frame(maxWidth: .infinity)
			.background(
				LinearGradient(
					colors: [.blue, .indigo],
					startPoint: .topLeading,
					endPoint: .bottomTrailing
				)
			)
			.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			.shadow(color: .black.opacity(0.12), radius: 12, y: 6)
		}
	}

	private var lotsListSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Detalle de ocupación")
				.font(.headline)

			ForEach(viewModel.lots) { lot in
				VStack(alignment: .leading, spacing: 10) {
					HStack {
						Text(lot.name)
							.font(.headline)
						Spacer()
						Text("\(lot.capacityUsed) / \(lot.capacityTotal) spots")
							.font(.subheadline)
							.foregroundStyle(.secondary)
					}

					ProgressView(value: lot.occupancyPercentage / 100)
						.tint(color(for: lot.occupancyPercentage))
				}
				.padding()
				.background(.thinMaterial)
				.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			}
		}
	}

	// MARK: - Helpers

	private func color(for occupancy: Double) -> Color {
		if occupancy < 0.7 {
			return .green
		} else if occupancy < 0.9 {
			return .orange
		} else {
			return .red
		}
	}
}

// MARK: - Parking Lot Card

private struct ParkingLotCard: View {
	let lot: ParkingLot

	var body: some View {
		let occupancy = lot.occupancyPercentage

		VStack(alignment: .leading, spacing: 12) {
			HStack {
				Text(lot.name)
					.font(.headline)
					.foregroundStyle(.primary)
				Spacer()
				Circle()
					.fill(statusColor)
					.frame(width: 10, height: 10)
			}

			Text("\(lot.capacityUsed) / \(lot.capacityTotal) spots")
				.font(.subheadline)
				.foregroundStyle(.secondary)

			ProgressView(value: occupancy)
				.tint(statusColor)
		}
		.padding()
		.frame(width: 220)
		.background(.thinMaterial)
		.overlay(
			RoundedRectangle(cornerRadius: 16, style: .continuous)
				.strokeBorder(statusColor.opacity(0.18), lineWidth: 1)
		)
		.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
		.shadow(color: .black.opacity(0.10), radius: 10, y: 5)
	}

	private var statusColor: Color {
		let occupancy = lot.occupancyPercentage
		if occupancy < 0.7 {
			return .green
		} else if occupancy < 0.9 {
			return .orange
		} else {
			return .red
		}
	}
}