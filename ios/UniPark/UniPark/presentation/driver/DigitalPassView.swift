import SwiftUI
import UIKit
import Observation
import CoreImage
import CoreImage.CIFilterBuiltins

public struct DigitalPassView: View {
	@State private var viewModel = DigitalPassViewModel()

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

						if let qr = viewModel.qrImage {
							qr
								.resizable()
								.interpolation(.none)
								.frame(width: 220, height: 220)
								.scaledToFit()
								.padding(0)
						} else {
							ProgressView()
								.tint(.white)
						}
					}

					Text("Expira en \(viewModel.secondsRemaining)s")
						.font(.headline)
						.foregroundStyle(viewModel.secondsRemaining < 15 ? .red : .secondary)
						.fontWeight(viewModel.secondsRemaining < 15 ? .bold : .regular)

					Button {
						// NFC placeholder
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
			viewModel.startTimer()
		}
		.onAppear {
			viewModel.startTimer()
		}
		.onDisappear {
			viewModel.stopTimer()
		}
	}

	// MARK: - QR Generation

	// All QR generation and timer logic moved to the ViewModel
}

// MARK: - View Model

@MainActor
@Observable
final class DigitalPassViewModel {
	private let generatePassUseCase: GeneratePassUseCase

	// MARK: - State
	var pass: Pass?
	var qrImage: Image?
	var secondsRemaining: Int = 60
	var timer: Timer?

	init(container: AppDIContainer = .shared) {
		self.generatePassUseCase = container.generatePassUseCase
	}

	// MARK: - Actions

	func generatePass() async {
		do {
			// keep vehicleId/userId returned by the backend; we will create ephemeral nonce/exp locally
			pass = try await generatePassUseCase.execute(vehicleId: UUID())
			secondsRemaining = 60
			generateAndSetQRCode()
		} catch {
			pass = nil
		}
	}

	// MARK: - QR Generation

	private func generateQRCode(from string: String) -> Image {
		let context = CIContext()
		let filter = CIFilter.qrCodeGenerator()
		filter.setValue(Data(string.utf8), forKey: "inputMessage")
		filter.setValue("M", forKey: "inputCorrectionLevel")

		guard var ciImage = filter.outputImage else {
			return Image(systemName: "xmark.octagon")
		}

		// Make QR white on black using FalseColor
		if let falseColor = CIFilter(name: "CIFalseColor") {
			falseColor.setValue(ciImage, forKey: kCIInputImageKey)
			falseColor.setValue(CIColor(color: .white), forKey: "inputColor0")
			falseColor.setValue(CIColor(color: .black), forKey: "inputColor1")
			if let output = falseColor.outputImage {
				ciImage = output
			}
		}

		// Scale to 220x220 points
		let targetSize: CGFloat = 220
		let extent = ciImage.extent.integral
		let scale = min(targetSize / extent.width, targetSize / extent.height)
		let transform = CGAffineTransform(scaleX: scale, y: scale)
		let scaled = ciImage.transformed(by: transform)

		if let cgImage = context.createCGImage(scaled, from: scaled.extent) {
			let uiImage = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
			return Image(uiImage: uiImage)
		}

		return Image(systemName: "xmark.octagon")
	}

	func generateAndSetQRCode() {
		guard let pass = pass else { qrImage = nil; return }

		let exp = Int(Date().addingTimeInterval(60).timeIntervalSince1970)
		let nonce = UUID().uuidString

		let payload: [String: Any] = [
			"userId": pass.userId.uuidString,
			"vehicleId": pass.vehicleId.uuidString,
			"exp": exp,
			"nonce": nonce
		]

		if let data = try? JSONSerialization.data(withJSONObject: payload, options: []),
		   let jsonString = String(data: data, encoding: .utf8) {
			qrImage = generateQRCode(from: jsonString)
		} else {
			qrImage = nil
		}
	}

	// MARK: - Timer

	func startTimer() {
		stopTimer()
		secondsRemaining = 60

		// schedule on main run loop; capture weak self since Timer retains target
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
			guard let self = self else { return }
			Task { @MainActor in
				self.tick()
			}
		}
	}

	func stopTimer() {
		timer?.invalidate()
		timer = nil
	}

	func tick() {
		if secondsRemaining > 0 {
			secondsRemaining -= 1
		}

		if secondsRemaining <= 0 {
			generateAndSetQRCode()
			secondsRemaining = 60
		}
	}
}