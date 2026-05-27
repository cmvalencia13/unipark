import SwiftUI
import Observation

@Observable
@MainActor
final class WalletViewModel {
	var balance: Double = 25.50
	var transactions: [WalletTransaction] = WalletViewModel.makeStubTransactions()
	var isProcessing: Bool = false
	var showPaymentSuccess: Bool = false
	var showPaymentError: Bool = false
	var lastAddedAmount: Double = 0.0

	private static func makeStubTransactions() -> [WalletTransaction] {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "es_ES")
		formatter.dateFormat = "yyyy-MM-dd HH:mm"

		func date(_ value: String) -> Date {
			formatter.date(from: value) ?? Date()
		}

		return [
			WalletTransaction(date: date("2026-05-26 08:15"), description: "Recarga inicial", amount: 25.50, type: .credit),
			WalletTransaction(date: date("2026-05-25 14:20"), description: "Estacionamiento Lote A", amount: 4.00, type: .debit),
			WalletTransaction(date: date("2026-05-24 09:10"), description: "Recarga rápida", amount: 10.00, type: .credit),
			WalletTransaction(date: date("2026-05-23 17:45"), description: "Estacionamiento Lote C", amount: 3.50, type: .debit),
			WalletTransaction(date: date("2026-05-22 11:05"), description: "Recarga rápida", amount: 20.00, type: .credit)
		]
	}

	func addFunds(amount: Double) async {
		guard !isProcessing else { return }

		isProcessing = true
		showPaymentError = false
		showPaymentSuccess = false
		lastAddedAmount = amount

		do {
			try await Task.sleep(for: .seconds(1.5))

			if Double.random(in: 0...1) < 0.05 {
				throw WalletPaymentError.rejected
			}

			balance += amount
			transactions.insert(
				WalletTransaction(
					date: Date(),
					description: "Recarga de saldo",
					amount: amount,
					type: .credit
				),
				at: 0
			)
			showPaymentSuccess = true
		} catch {
			showPaymentError = true
		}

		isProcessing = false
	}

}

struct WalletTransaction: Identifiable {
	enum TransactionType {
		case credit
		case debit
	}

	let id = UUID()
	let date: Date
	let description: String
	let amount: Double
	let type: TransactionType
}

private enum WalletPaymentError: Error {
	case rejected
}

public struct WalletView: View {
	@State private var viewModel = WalletViewModel()
	@State private var showSuccessSheet = false

	private let quickAmounts: [Double] = [5, 10, 20, 50]

	public init() {}

	public var body: some View {
		ScrollView {
			VStack(spacing: 16) {
				balanceCard
				quickActionsCard
				paymentMethodsCard
				transactionsCard
			}
			.padding()
		}
		.navigationTitle("Wallet")
		.navigationBarTitleDisplayMode(.inline)
		.overlay {
			if viewModel.isProcessing {
				processingOverlay
			}
		}
		.sheet(isPresented: $showSuccessSheet) {
			successSheet
		}
		.alert("Pago rechazado", isPresented: $viewModel.showPaymentError) {
			Button("OK", role: .cancel) {}
		} message: {
			Text("Tu pago fue rechazado por el sistema de seguridad. Intenta de nuevo.")
		}
		.onChange(of: viewModel.showPaymentSuccess) { _, newValue in
			showSuccessSheet = newValue
		}
		.onChange(of: showSuccessSheet) { _, newValue in
			if !newValue { viewModel.showPaymentSuccess = false }
		}
	}

	private var balanceCard: some View {
		RoundedRectangle(cornerRadius: 16, style: .continuous)
			.fill(
				LinearGradient(
					colors: [Color.blue, Color.indigo, Color.cyan],
					startPoint: .topLeading,
					endPoint: .bottomTrailing
				)
			)
			.overlay(alignment: .leading) {
				VStack(alignment: .leading, spacing: 8) {
					Label("Saldo disponible", systemImage: "creditcard.fill")
						.font(.subheadline.weight(.semibold))
						.foregroundStyle(.white.opacity(0.9))

					Text(balanceText)
						.font(.system(size: 38, weight: .bold, design: .rounded))
						.foregroundStyle(.white)

					Text("Recarga tu Wallet para pagar estacionamientos y multas.")
						.font(.footnote)
						.foregroundStyle(.white.opacity(0.85))
				}
				.padding(20)
			}
			.frame(height: 170)
	}

	private var quickActionsCard: some View {
		VStack(alignment: .leading, spacing: 14) {
			Text("Recarga rápida")
				.font(.headline)

			HStack(spacing: 10) {
				ForEach(quickAmounts, id: \.self) { amount in
					Button {
						Task { await viewModel.addFunds(amount: amount) }
					} label: {
						Text("+$\(Int(amount))")
							.font(.subheadline.bold())
							.frame(maxWidth: .infinity)
							.frame(height: 44)
							.foregroundStyle(.primary)
							.background(Color(.secondarySystemBackground))
							.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
					}
					.disabled(viewModel.isProcessing)
				}
			}

			if viewModel.isProcessing {
				HStack(spacing: 10) {
					ProgressView()
					Text("Procesando pago...")
						.font(.subheadline.weight(.semibold))
				}
				.foregroundStyle(.secondary)
				.frame(maxWidth: .infinity, alignment: .leading)
			}
		}
		.padding()
		.background(Color(.secondarySystemBackground))
		.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
		.disabled(viewModel.isProcessing)
		.opacity(viewModel.isProcessing ? 0.95 : 1)
	}

	private var paymentMethodsCard: some View {
		VStack(alignment: .leading, spacing: 14) {
			Text("Métodos de pago")
				.font(.headline)

			HStack(spacing: 12) {
				Image(systemName: "creditcard.fill")
					.font(.title2)
					.foregroundStyle(.blue)

				VStack(alignment: .leading, spacing: 2) {
					Text("Visa •••• 4242")
						.font(.subheadline.weight(.semibold))
					Text("Terminada en 4242")
						.font(.caption)
						.foregroundStyle(.secondary)
				}

				Spacer()
			}
			.padding()
			.background(Color(.tertiarySystemBackground))
			.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

			Button {
				// Non-functional UI only
			} label: {
				HStack(spacing: 10) {
					Image(systemName: "apple.logo")
					Text("Apple Pay")
						.fontWeight(.semibold)
				}
				.frame(maxWidth: .infinity)
				.frame(height: 48)
				.foregroundStyle(.white)
				.background(Color.black)
				.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			}
			.disabled(viewModel.isProcessing)
		}
		.padding()
		.background(Color(.secondarySystemBackground))
		.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
	}

	private var transactionsCard: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Movimientos")
				.font(.headline)
				.padding(.horizontal)

			List(viewModel.transactions) { transaction in
				HStack(alignment: .top, spacing: 12) {
					Image(systemName: transaction.type == .credit ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
						.foregroundStyle(transaction.type == .credit ? .green : .red)
						.font(.title3)

					VStack(alignment: .leading, spacing: 4) {
						Text(transaction.description)
							.font(.subheadline.weight(.semibold))
						Text(Self.transactionDateFormatter.string(from: transaction.date))
							.font(.caption)
							.foregroundStyle(.secondary)
					}

					Spacer()

					Text(transactionAmountText(transaction))
						.font(.subheadline.weight(.bold))
						.foregroundStyle(transaction.type == .credit ? .green : .red)
				}
				.padding(.vertical, 4)
				.listRowBackground(Color.clear)
			}
			.frame(minHeight: 340)
			.scrollContentBackground(.hidden)
			.listStyle(.plain)
		}
		.padding(.vertical, 8)
		.background(Color(.secondarySystemBackground))
		.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
	}

	private var processingOverlay: some View {
		ZStack {
			Color.black.opacity(0.35)
				.ignoresSafeArea()

			VStack(spacing: 12) {
				ProgressView()
					.tint(.white)
				Text("Procesando pago...")
					.font(.headline)
					.foregroundStyle(.white)
			}
			.padding(24)
			.background(Color(.systemGray6).opacity(0.95))
			.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			.shadow(radius: 20)
		}
	}

	private var successSheet: some View {
		VStack(spacing: 18) {
			Image(systemName: "checkmark.circle.fill")
				.font(.system(size: 64))
				.foregroundStyle(.green)

			Text("Recarga exitosa")
				.font(.title2.bold())

			Text("Se agregaron +\(currency(viewModel.lastAddedAmount)) a tu saldo.")
				.multilineTextAlignment(.center)
				.foregroundStyle(.secondary)

			Button("Cerrar") {
				showSuccessSheet = false
				viewModel.showPaymentSuccess = false
			}
			.frame(maxWidth: .infinity)
			.frame(height: 48)
			.foregroundStyle(.white)
			.background(Color.blue)
			.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
		}
		.padding(24)
		.presentationDetents([.medium])
	}

	private var balanceText: String {
		currency(viewModel.balance)
	}

	private func currency(_ value: Double) -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencySymbol = "$"
		formatter.minimumFractionDigits = 2
		formatter.maximumFractionDigits = 2
		return formatter.string(from: NSNumber(value: value)) ?? "$ 0.00"
	}

	private func transactionAmountText(_ transaction: WalletTransaction) -> String {
		let sign = transaction.type == .credit ? "+" : "-"
		return "\(sign)\(currency(transaction.amount))"
	}

	private static let transactionDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "es_ES")
		formatter.dateFormat = "dd MMM"
		return formatter
	}()
}