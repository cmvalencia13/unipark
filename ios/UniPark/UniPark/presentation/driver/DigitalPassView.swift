import SwiftUI
import Observation

public struct DigitalPassView: View {
	@State private var viewModel = DigitalPassViewModel()
	@State private var timer: Timer?

	public init() {}

	public var body: some View {
		ScrollView {
			VStack(spacing: 20) {
				VStack(alignment: .leading, spacing: 8) {
					Text("Tu Pase Digital")
						.font(.title2.bold())
					Text("Presenta este pase cuando llegues al acceso.")
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding()
				.background(.thinMaterial)
				.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

				VStack(spacing: 16) {
					ZStack {
						RoundedRectangle(cornerRadius: 16, style: .continuous)
							.fill(.black)
							.frame(width: 260, height: 260)

						if let qrImage = viewModel.qrImage {
							qrImage
								.resizable()
								.scaledToFit()
								.padding(30)
						}
					}

					Text("Expira en \(viewModel.secondsRemaining)s")
						.font(.headline)
						.foregroundStyle(viewModel.secondsRemaining < 15 ? .red : .secondary)

					Button {
						Task {
							await viewModel.generatePass()
							resetTimer()
						}
					} label: {
						HStack(spacing: 10) {
							Image(systemName: "antenna.radiowaves.left.and.right")
							Text("NFC")
						}
						.font(.headline)
						.foregroundStyle(.white)
						.frame(maxWidth: .infinity)
						.padding()
						.background(Color.accentColor)
						.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
					}
				}
				.padding()
				.background(.thinMaterial)
				.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			}
			.padding()
		}
		.navigationTitle("Pase Digital")
		.navigationBarTitleDisplayMode(.inline)
		.task {
			await viewModel.generatePass()
			resetTimer()
		}
		.onDisappear {
			timer?.invalidate()
			timer = nil
		}
	}

	// MARK: - Timer

	private func resetTimer() {
		timer?.invalidate()
		viewModel.secondsRemaining = 60

		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak viewModel] timer in
			guard let viewModel else {
				timer.invalidate()
				return
			}

			if viewModel.secondsRemaining > 0 {
				viewModel.secondsRemaining -= 1
			}

			if viewModel.secondsRemaining <= 0 {
				timer.invalidate()
				Task {
					await viewModel.generatePass()
					resetTimer()
				}
			}
		}
	}
}

// MARK: - View Model

@MainActor
@Observable
final class DigitalPassViewModel {
	private let generatePassUseCase: GeneratePassUseCase

	var pass: Pass?
	var qrImage: Image?
	var secondsRemaining: Int = 60

	init(container: AppDIContainer = .shared) {
		self.generatePassUseCase = container.generatePassUseCase
	}

	// MARK: - Actions

	func generatePass() async {
		do {
			pass = try await generatePassUseCase.execute(vehicleId: UUID())
			qrImage = nil
			secondsRemaining = 60
		} catch {
			pass = nil
			qrImage = nil
		}
	}
}