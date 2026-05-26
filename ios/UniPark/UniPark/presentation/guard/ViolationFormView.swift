import SwiftUI

public struct ViolationFormView: View {
	@State private var vehiclePlate: String = ""
	@State private var selectedLotId: UUID?
	@State private var reason: String = ""
	@State private var lots: [ParkingLot] = []
	@State private var showSuccessSheet: Bool = false
	@State private var isLoading: Bool = false
	@State private var errorMessage: String?
	
	private let manageLotUseCase = AppDIContainer.shared.manageLotUseCase
	private let manageViolationUseCase = AppDIContainer.shared.manageViolationUseCase
	
	public init() {}
	
	public var body: some View {
		NavigationStack {
			Form {
				Section("Información de la Violación") {
					TextField("Placa del Vehículo", text: $vehiclePlate)
						.textInputAutocapitalization(.characters)
					
					Picker("Lote", selection: $selectedLotId) {
						Text("Seleccionar lote").tag(Optional(UUID()))
						
						ForEach(lots, id: \.id) { lot in
							Text(lot.name)
								.tag(Optional(lot.id))
						}
					}
				}
				
				Section("Razón de la Violación") {
					TextEditor(text: $reason)
						.frame(minHeight: 100)
						.scrollContentBackground(.hidden)
				}
				
				Section {
					Button(action: {
						// Placeholder for camera action
					}) {
						HStack {
							Image(systemName: "camera.fill")
								.font(.system(size: 16))
							Text("Agregar Foto")
						}
						.frame(maxWidth: .infinity)
						.foregroundStyle(.blue)
					}
				}
			}
			.navigationTitle("Reportar Violación")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button("Enviar") {
						submitViolation()
					}
					.disabled(isFormInvalid || isLoading)
					.opacity(isFormInvalid || isLoading ? 0.6 : 1)
				}
			}
		}
		.sheet(isPresented: $showSuccessSheet) {
			successSheet
		}
		.alert("Error", isPresented: .constant(errorMessage != nil)) {
			Button("OK") {
				errorMessage = nil
			}
		} message: {
			if let errorMessage = errorMessage {
				Text(errorMessage)
			}
		}
		.task {
			await loadLots()
		}
	}
	
	private var isFormInvalid: Bool {
		vehiclePlate.trimmingCharacters(in: .whitespaces).isEmpty ||
		selectedLotId == nil ||
		reason.trimmingCharacters(in: .whitespaces).isEmpty
	}
	
	private var successSheet: some View {
		VStack(spacing: 20) {
			VStack(spacing: 12) {
				Image(systemName: "checkmark.circle.fill")
					.font(.system(size: 60))
					.foregroundStyle(.green)
				
				Text("Violación Reportada")
					.font(.headline)
				
				Text("El reporte ha sido enviado correctamente.")
					.font(.subheadline)
					.foregroundStyle(.secondary)
					.multilineTextAlignment(.center)
			}
			.frame(maxWidth: .infinity)
			
			Button(action: {
				resetForm()
				showSuccessSheet = false
			}) {
				Text("Realizar Otro Reporte")
					.frame(maxWidth: .infinity)
					.frame(height: 44)
					.background(Color.blue)
					.foregroundStyle(.white)
					.cornerRadius(8)
			}
			
			Button(action: {
				showSuccessSheet = false
			}) {
				Text("Cerrar")
					.frame(maxWidth: .infinity)
					.frame(height: 44)
					.foregroundStyle(.blue)
			}
		}
		.padding()
		.presentationDetents([.fraction(0.4)])
		.presentationDragIndicator(.visible)
	}
	
	private func loadLots() async {
		do {
			lots = try await manageLotUseCase.fetchAll()
		} catch {
			errorMessage = "Error cargando lotes"
		}
	}
	
	private func submitViolation() {
		Task {
			isLoading = true
			errorMessage = nil
			
			do {
				_ = try await manageViolationUseCase.report(
					vehicleId: nil,
					lotId: selectedLotId,
					reason: reason,
					evidenceUrl: nil
				)
				
				showSuccessSheet = true
			} catch {
				errorMessage = error.localizedDescription
			}
			
			isLoading = false
		}
	}
	
	private func resetForm() {
		vehiclePlate = ""
		selectedLotId = nil
		reason = ""
	}
}

#Preview {
	ViolationFormView()
}
