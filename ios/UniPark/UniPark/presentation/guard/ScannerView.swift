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
	
	private let manageLotUseCase = AppDIContainer.shared.manageLotUseCase
	
	public init() {}
	
	public var body: some View {
		VStack(spacing: 0) {
			// Top: Lot Selector
			VStack(spacing: 8) {
				Text("Seleccionar Lote")
					.font(.caption)
					.foregroundStyle(.secondary)
				
				Picker("Lote", selection: $viewModel.selectedLotId) {
					ForEach(lots, id: \.id) { lot in
						Text(lot.name)
							.tag(Optional(lot.id))
					}
				}
				.pickerStyle(.segmented)
			}
			.padding()
			.background(Color(.systemBackground))
			.border(Color(.systemGray5), width: 1)
			
			// Center: Camera Viewfinder
			VStack {
				ZStack {
					RoundedRectangle(cornerRadius: 20)
						.fill(Color.black)
					
					// Scanning line animation
					VStack {
						Spacer()
						
						HStack {
							Rectangle()
								.fill(Color.white)
								.frame(height: 2)
						}
						.frame(height: 80)
						.offset(y: viewModel.isScanning ? 100 : -100)
						.animation(
							Animation.linear(duration: 2).repeatForever(autoreverses: false),
							value: viewModel.isScanning
						)
						
						Spacer()
					}
					
					VStack {
						Spacer()
						
						Text("Apunta al QR del conductor")
							.font(.system(.body, design: .rounded))
							.fontWeight(.semibold)
							.foregroundStyle(.white)
						
						Spacer()
					}
				}
				.frame(height: 300)
				.padding()
			}
			.frame(maxHeight: .infinity)
			.background(Color(.systemGray6))
			
			// Center Bottom: Action Buttons
			HStack(spacing: 16) {
				Button(action: {
					Task {
						await viewModel.scan(
							passPayload: "stub_payload_entry",
							passSignature: "stub_signature_entry",
							direction: .entry
						)
					}
				}) {
					HStack(spacing: 8) {
						Image(systemName: "arrow.up.circle.fill")
							.font(.system(size: 20))
						Text("Entrada")
							.fontWeight(.semibold)
					}
					.frame(maxWidth: .infinity)
					.frame(height: 50)
					.background(Color.green)
					.foregroundStyle(.white)
					.cornerRadius(12)
				}
				.disabled(viewModel.isButtonDisabled || viewModel.selectedLotId == nil)
				.opacity(viewModel.isButtonDisabled || viewModel.selectedLotId == nil ? 0.6 : 1)
				
				Button(action: {
					Task {
						await viewModel.scan(
							passPayload: "stub_payload_exit",
							passSignature: "stub_signature_exit",
							direction: .exit
						)
					}
				}) {
					HStack(spacing: 8) {
						Image(systemName: "arrow.down.circle.fill")
							.font(.system(size: 20))
						Text("Salida")
							.fontWeight(.semibold)
					}
					.frame(maxWidth: .infinity)
					.frame(height: 50)
					.background(Color.red)
					.foregroundStyle(.white)
					.cornerRadius(12)
				}
				.disabled(viewModel.isButtonDisabled || viewModel.selectedLotId == nil)
				.opacity(viewModel.isButtonDisabled || viewModel.selectedLotId == nil ? 0.6 : 1)
			}
			.padding()
			.background(Color(.systemBackground))
			
			// Bottom: Last Scan Card
			if let scan = viewModel.lastScan {
				VStack(alignment: .leading, spacing: 12) {
					HStack {
						VStack(alignment: .leading, spacing: 4) {
							Text(scan.direction == .entry ? "Entrada Registrada" : "Salida Registrada")
								.font(.headline)
								.foregroundStyle(scan.direction == .entry ? .green : .red)
							
							Text(scan.scannedAt, style: .time)
								.font(.caption)
								.foregroundStyle(.secondary)
						}
						
						Spacer()
						
						Image(systemName: scan.direction == .entry ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
							.font(.system(size: 24))
							.foregroundStyle(scan.direction == .entry ? .green : .red)
					}
				}
				.frame(maxWidth: .infinity)
				.padding()
				.background(Color(.systemGray6))
				.cornerRadius(12)
				.padding()
			}
			
			if let errorMessage = viewModel.errorMessage {
				Text(errorMessage)
					.font(.caption)
					.foregroundStyle(.red)
					.padding()
			}
		}
		.task {
			await loadLots()
		}
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
}

#Preview {
	ScannerView()
}