import SwiftUI

public struct ViolationsTab: View {
    @State var viewModel: GuardViewModel
    @State private var showNewViolationSheet = false
    @State private var dismissSuccessAlert = false
    
    public init(viewModel: GuardViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            Color.upBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    HStack(spacing: 0) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.upSurface)
                            .frame(width: 40, height: 40)
                            .background(Color.upSurfaceHighest)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("UniPark")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(Color.upPrimary)
                        }
                        .padding(.leading, 8)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showNewViolationSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.upPrimary)
                    }
                    
                    Button(action: {
                        NotificationCenter.default.post(name: Notification.Name("signOut"), object: nil)
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.upTextSecondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.upSurface)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        if viewModel.violationSubmitSuccess {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.upSecondary)
                                Text("Infracción registrada exitosamente")
                                    .font(.caption)
                                    .foregroundStyle(Color.upTextPrimary)
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.upSecondary.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    viewModel.violationSubmitSuccess = false
                                }
                            }
                        }
                        
                        Text("INFRACCIONES")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.upPrimary)
                            .textCase(.uppercase)
                            .kerning(1.2)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                        
                        if viewModel.violations.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(Color.upSecondary)
                                
                                Text("Sin infracciones")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.upTextPrimary)
                                
                                Text("Presiona + para registrar una nueva infracción")
                                    .font(.caption)
                                    .foregroundStyle(Color.upTextSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(viewModel.violations, id: \.id) { violation in
                                    ViolationRow(violation: violation)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showNewViolationSheet) {
            NewViolationSheet(
                viewModel: viewModel,
                isPresented: $showNewViolationSheet
            )
        }
    }
}

private struct ViolationRow: View {
    let violation: ViolationEntry
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Status dot
            Circle()
                .fill(statusColor(violation.status))
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(violation.plate)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.upTextPrimary)
                    
                    Text(violation.reason.rawValue)
                        .font(.caption)
                        .foregroundStyle(Color.upTextSecondary)
                }
                
                HStack(spacing: 12) {
                    Label(violation.lotName, systemImage: "building.2.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.upTextSecondary)
                    
                    Label(formatDate(violation.createdAt), systemImage: "calendar")
                        .font(.caption2)
                        .foregroundStyle(Color.upTextSecondary)
                    
                    if violation.hasPhoto {
                        Image(systemName: "photo.fill")
                            .font(.caption2)
                            .foregroundStyle(Color.upPrimary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.upSurface)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.upSurfaceHighest, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func statusColor(_ status: ViolationEntry.ViolationStatus) -> Color {
        switch status {
        case .pending:
            return .orange
        case .approved:
            return .upSecondary
        case .dismissed:
            return Color.upTextSecondary
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        return formatter.string(from: date)
    }
}

private struct NewViolationSheet: View {
    @State var viewModel: GuardViewModel
    @Binding var isPresented: Bool
    
    @State private var plate = ""
    @State private var selectedLotId: UUID?
    @State private var selectedReason: ViolationEntry.ViolationReason?
    @State private var hasPhoto = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Placa del Vehículo") {
                    TextField("Ej: ABC-123", text: $plate)
                        .textFieldStyle(.roundedBorder)
                }
                
                Section("Lote") {
                    Picker("Seleccionar lote", selection: $selectedLotId) {
                        Text("Ninguno").tag(UUID?.none)
                        ForEach(viewModel.lots, id: \.id) { lot in
                            Text(lot.name).tag(Optional(lot.id))
                        }
                    }
                }
                
                Section("Razón") {
                    Picker("Seleccionar razón", selection: $selectedReason) {
                        Text("Ninguna").tag(ViolationEntry.ViolationReason?.none)
                        ForEach([
                            ViolationEntry.ViolationReason.badParking,
                            ViolationEntry.ViolationReason.noScan,
                            ViolationEntry.ViolationReason.wrongLot,
                            ViolationEntry.ViolationReason.hitAndRun,
                            ViolationEntry.ViolationReason.passAbuse
                        ], id: \.self) { reason in
                            Text(reason.rawValue).tag(Optional(reason))
                        }
                    }
                }
                
                Section("Adjuntos") {
                    Toggle("Foto del incidente", isOn: $hasPhoto)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.upBackground)
            .navigationTitle("Nueva Infracción")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                    .foregroundStyle(Color.upTextSecondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Registrar") {
                        if !plate.isEmpty, let lotId = selectedLotId, let reason = selectedReason {
                            Task {
                                let violation = ViolationEntry(
                                    plate: plate,
                                    lotName: viewModel.lots.first(where: { $0.id == lotId })?.name ?? "Desconocido",
                                    reason: reason,
                                    hasPhoto: hasPhoto
                                )
                                viewModel.submitViolation(violation)
                                isPresented = false
                            }
                        }
                    }
                    .foregroundStyle(Color.upPrimary)
                    .disabled(plate.isEmpty || selectedLotId == nil || selectedReason == nil)
                }
            }
        }
    }
}
