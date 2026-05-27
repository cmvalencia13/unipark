import SwiftUI

@Observable
@MainActor
final class ScannerViewModel {
	var isScanning: Bool = false
	var lastScan: Scan?
	var errorMessage: String?
	var selectedLotId: UUID?
	var isButtonDisabled: Bool = false
	
	private let logEntryUseCase = AppDIContainer.shared.logEntryUseCase
	private let logExitUseCase = AppDIContainer.shared.logExitUseCase
	
	func scan(passPayload: String, passSignature: String, direction: ScanDirection) async {
		isButtonDisabled = true
		isScanning = true
		errorMessage = nil
		
		guard let lotId = selectedLotId else {
			errorMessage = "Por favor selecciona un lote"
			isScanning = false
			isButtonDisabled = false
			return
		}
		
		do {
			let result: (scan: Scan, lot: ParkingLot)
			
			switch direction {
			case .entry:
				result = try await logEntryUseCase.execute(
					passPayload: passPayload,
					passSignature: passSignature,
					lotId: lotId
				)
			case .exit:
				result = try await logExitUseCase.execute(
					passPayload: passPayload,
					passSignature: passSignature,
					lotId: lotId
				)
			}
			
			lastScan = result.scan
			isScanning = false
			
			// Re-enable buttons after 2 seconds
			try await Task.sleep(for: .seconds(2))
			isButtonDisabled = false
		} catch {
			errorMessage = error.localizedDescription
			isScanning = false
			isButtonDisabled = false
		}
	}
}

public struct ScannerView: View {
	@State private var viewModel = ScannerViewModel()
	@State private var lots: [ParkingLot] = []
	@State private var scanLineAnimating = false
	
	private let manageLotUseCase = AppDIContainer.shared.manageLotUseCase
	
	public init() {}
	
	public var body: some View {
		ZStack {
			Color.upBackground
				.ignoresSafeArea()

			ScrollView(showsIndicators: false) {
				VStack(alignment: .leading, spacing: 18) {
					header

					lotSelectorCard

					viewfinder

					actionButtons

					if let scan = viewModel.lastScan {
						successCard(for: scan)
					}

					if let errorMessage = viewModel.errorMessage {
						Text(errorMessage)
							.font(.caption)
							.foregroundStyle(Color.upError)
							.padding(.horizontal, 4)
					}
				}
				.padding(.horizontal, 16)
				.padding(.top, 20)
				.padding(.bottom, 24)
			}
		}
		.onAppear {
			scanLineAnimating = true
		}
		.task {
			await loadLots()
		}
	}

	private var header: some View {
		HStack(spacing: 12) {
			Image(systemName: "person.crop.circle.fill")
				.font(.title)
				.foregroundStyle(Color.upPrimary)
				.padding(8)
				.background(Color.upSurfaceHighest)
				.clipShape(Circle())

			VStack(alignment: .leading, spacing: 2) {
				Text("UniPark")
					.font(.title2.weight(.bold))
					.foregroundStyle(Color.upPrimary)

				Text("Guard Mode")
					.font(.subheadline)
					.foregroundStyle(Color.upTextSecondary)
			}

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
	}

	private var lotSelectorCard: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("SELECT LOT")
				.font(.system(size: 11, weight: .semibold))
				.foregroundStyle(Color.upPrimary)
				.textCase(.uppercase)
				.kerning(1.2)

			Picker("Lote", selection: $viewModel.selectedLotId) {
				ForEach(lots, id: \.id) { lot in
					Text(lot.name)
						.tag(Optional(lot.id))
				}
			}
			.pickerStyle(.menu)
			.tint(Color.upPrimary)
			.padding(.horizontal, 12)
			.padding(.vertical, 10)
			.background(Color.upSurfaceLowest.opacity(0.95))
			.overlay(
				RoundedRectangle(cornerRadius: 14, style: .continuous)
					.stroke(Color.upOutlineVariant, lineWidth: 1)
			)
			.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
		}
		.padding(16)
		.glassCard(cornerRadius: 18, glowColor: .upPrimary)
	}

	private var viewfinder: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 20, style: .continuous)
				.fill(Color.black)
				.overlay(
					RoundedRectangle(cornerRadius: 20, style: .continuous)
						.stroke(Color.upOutlineVariant, lineWidth: 1)
				)

			GeometryReader { proxy in
				let width = proxy.size.width
				let height = proxy.size.height
				let cornerLength: CGFloat = 20
				let cornerThickness: CGFloat = 2

				ZStack {
					Rectangle()
						.fill(
							LinearGradient(
								colors: [.clear, .upPrimary, .upSecondary, .clear],
								startPoint: .leading,
								endPoint: .trailing
							)
						)
						.frame(height: 2)
						.offset(y: scanLineAnimating ? height * 0.68 : height * 0.18)
						.animation(
							.linear(duration: 2.2).repeatForever(autoreverses: false),
							value: scanLineAnimating
						)

					cornerBrackets(width: width, height: height, length: cornerLength, thickness: cornerThickness)

					Text("APUNTA AL QR DEL CONDUCTOR")
						.font(.system(size: 12, weight: .semibold))
						.foregroundStyle(Color.upTextSecondary)
						.textCase(.uppercase)
						.kerning(1.3)
						.multilineTextAlignment(.center)
						.padding(.horizontal, 24)
				}
			}
		}
		.frame(height: 320)
		.padding(16)
		.background(Color.upSurfaceLowest.opacity(0.8))
		.clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
		.overlay(
			RoundedRectangle(cornerRadius: 24, style: .continuous)
				.stroke(Color.upOutlineVariant, lineWidth: 1)
		)
	}

	private var actionButtons: some View {
		HStack(spacing: 14) {
			Button(action: {
				Task {
					await viewModel.scan(
						passPayload: "stub_payload_entry",
						passSignature: "stub_signature_entry",
						direction: .entry
					)
				}
			}) {
				HStack(spacing: 10) {
					Image(systemName: "arrow.up.circle.fill")
					Text("Entrada")
				}
				.font(.headline)
				.frame(maxWidth: .infinity)
				.frame(height: 52)
				.foregroundStyle(Color.upSurfaceLowest)
				.background(Color.upSecondary)
				.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
				.neonGlow(color: .upSecondary)
			}
			.disabled(viewModel.isButtonDisabled || viewModel.selectedLotId == nil)
			.opacity(viewModel.isButtonDisabled || viewModel.selectedLotId == nil ? 0.65 : 1)

			Button(action: {
				Task {
					await viewModel.scan(
						passPayload: "stub_payload_exit",
						passSignature: "stub_signature_exit",
						direction: .exit
					)
				}
			}) {
				HStack(spacing: 10) {
					Image(systemName: "arrow.down.circle")
					Text("Salida")
				}
				.font(.headline)
				.frame(maxWidth: .infinity)
				.frame(height: 52)
				.foregroundStyle(Color.upError)
				.background(Color.clear)
				.overlay(
					RoundedRectangle(cornerRadius: 14, style: .continuous)
						.stroke(Color.upError, lineWidth: 1)
				)
				.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
			}
			.disabled(viewModel.isButtonDisabled || viewModel.selectedLotId == nil)
			.opacity(viewModel.isButtonDisabled || viewModel.selectedLotId == nil ? 0.65 : 1)
		}
	}

	private func successCard(for scan: Scan) -> some View {
		HStack(alignment: .top, spacing: 12) {
			Rectangle()
				.fill(Color.upSecondary)
				.frame(width: 4)
				.clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))

			Image(systemName: "checkmark.circle.fill")
				.font(.system(size: 24))
				.foregroundStyle(Color.upSecondary)

			VStack(alignment: .leading, spacing: 4) {
				Text("Driver Name")
					.font(.headline.weight(.bold))
					.foregroundStyle(Color.upTextPrimary)

				Text(scan.direction == .entry ? "Entrada registrada" : "Salida registrada")
					.font(.subheadline)
					.foregroundStyle(Color.upTextSecondary)

				Text(scan.scannedAt, style: .time)
					.font(.caption)
					.foregroundStyle(Color.upTextSecondary)
			}

			Spacer()
		}
		.padding(16)
		.glassCard(cornerRadius: 18, glowColor: .upSecondary)
	}
	
	private func loadLots() async {
		do {
			lots = try await manageLotUseCase.fetchAll()
			if viewModel.selectedLotId == nil && !lots.isEmpty {
				viewModel.selectedLotId = lots[0].id
			}
		} catch {
			viewModel.errorMessage = "Error cargando lotes"
		}
	}

	private func cornerBrackets(width: CGFloat, height: CGFloat, length: CGFloat, thickness: CGFloat) -> some View {
		ZStack {
			cornerBracket(x: 0, y: 0, horizontalFromLeft: true, verticalFromTop: true, length: length, thickness: thickness)
			cornerBracket(x: width, y: 0, horizontalFromLeft: false, verticalFromTop: true, length: length, thickness: thickness)
			cornerBracket(x: 0, y: height, horizontalFromLeft: true, verticalFromTop: false, length: length, thickness: thickness)
			cornerBracket(x: width, y: height, horizontalFromLeft: false, verticalFromTop: false, length: length, thickness: thickness)
		}
	}

	private func cornerBracket(
		x: CGFloat,
		y: CGFloat,
		horizontalFromLeft: Bool,
		verticalFromTop: Bool,
		length: CGFloat,
		thickness: CGFloat
	) -> some View {
		ZStack {
			Rectangle()
				.fill(Color.upPrimary)
				.frame(width: length, height: thickness)
				.offset(x: horizontalFromLeft ? length / 2 : -length / 2, y: 0)

			Rectangle()
				.fill(Color.upPrimary)
				.frame(width: thickness, height: length)
				.offset(x: 0, y: verticalFromTop ? length / 2 : -length / 2)
		}
		.position(x: x, y: y)
	}
}

#Preview {
	ScannerView()
}