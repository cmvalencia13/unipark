import SwiftUI
import UIKit
import Observation
import CoreImage
import CoreImage.CIFilterBuiltins

public struct DigitalPassView: View {
	@State private var viewModel = DigitalPassViewModel()

	public init() {}

	public var body: some View {
		NavigationStack {
			ZStack {
				Color.upBackground
					.ignoresSafeArea()

				ScrollView(showsIndicators: false) {
					VStack(spacing: 18) {
						header

						destinationCard

						accessRing

						Text("TAP TO ENTER")
							.font(.system(size: 13, weight: .bold))
							.foregroundStyle(Color.upPrimary)
							.textCase(.uppercase)
							.kerning(1.8)

						VStack(spacing: 10) {
							HStack(spacing: 8) {
								GlowingDot(color: .upSecondary, size: 6)
								Text("SYSTEM READY")
									.font(.system(size: 11, weight: .semibold))
									.foregroundStyle(Color.upTextSecondary)
									.textCase(.uppercase)
									.kerning(1.2)
							}

							Text("Refreshes in \(viewModel.secondsRemaining)s")
								.font(.headline.weight(.semibold))
								.foregroundStyle(Color.upPrimary)
						}

						Button {
							// Assistance action placeholder
						} label: {
							HStack(spacing: 10) {
								Image(systemName: "questionmark.circle")
								Text("Need Assistance?")
							}
							.font(.subheadline.weight(.semibold))
							.foregroundStyle(Color.upTextSecondary)
							.frame(maxWidth: .infinity)
							.padding(.vertical, 14)
							.background(
								RoundedRectangle(cornerRadius: 16, style: .continuous)
									.stroke(Color.upOutlineVariant, lineWidth: 1)
							)
						}
						.padding(.top, 6)
					}
					.padding(.horizontal, 16)
					.padding(.top, 20)
					.padding(.bottom, 24)
				}
			}
		}
		.toolbar(.hidden, for: .navigationBar)
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
	}

	private var destinationCard: some View {
		HStack(alignment: .top, spacing: 14) {
			VStack(alignment: .leading, spacing: 8) {
				Text("DESTINATION")
					.font(.system(size: 11, weight: .semibold))
					.foregroundStyle(Color.upPrimary)
					.textCase(.uppercase)
					.kerning(1.2)

				Text("Lot C Entry")
					.font(.system(size: 22, weight: .bold))
					.foregroundStyle(Color.upTextPrimary)

				VStack(alignment: .leading, spacing: 4) {
					Text("AUTHORIZED VEHICLE")
						.font(.system(size: 10, weight: .semibold))
						.foregroundStyle(Color.upSecondary)
						.textCase(.uppercase)
						.kerning(1.0)

					Text(viewModel.pass?.vehicleId.uuidString.uppercased().prefix(8) ?? "ABC-123")
						.font(.subheadline.weight(.bold))
						.foregroundStyle(Color.upSecondary)
				}
			}

			Spacer()

			Image(systemName: "car.fill")
				.font(.system(size: 24, weight: .semibold))
				.foregroundStyle(Color.upPrimary)
				.padding(12)
				.background(Color.upSurfaceHighest.opacity(0.9))
				.clipShape(Circle())
		}
		.padding(16)
		.glassCard(cornerRadius: 18, glowColor: .upPrimary)
	}

	private var accessRing: some View {
		ZStack {
			Circle()
				.fill(
					RadialGradient(
						colors: [Color.upSurface, Color.upBackground],
						center: .center,
						startRadius: 24,
						endRadius: 120
					)
				)
				.frame(width: 240, height: 240)

			Circle()
				.stroke(Color.upOutlineVariant, lineWidth: 1)
				.frame(width: 240, height: 240)

			Circle()
				.stroke(
					AngularGradient(
						colors: [Color.upPrimary, Color.upSecondary, Color.upPrimary],
						center: .center
					),
					lineWidth: 12
				)
				.frame(width: 224, height: 224)
				.neonGlow(color: .upSecondary, radius: 24)

			Circle()
				.fill(
					RadialGradient(
						colors: [Color.upSurfaceHighest, Color.upSurface, Color.upBackground],
						center: .center,
						startRadius: 12,
						endRadius: 120
					)
				)
				.frame(width: 180, height: 180)
				.overlay {
					if let qr = viewModel.qrImage {
						qr
							.resizable()
							.interpolation(.none)
							.scaledToFit()
							.padding(28)
					} else {
						Image(systemName: "qrcode.viewfinder")
							.font(.system(size: 60, weight: .semibold))
							.foregroundStyle(Color.upPrimary)
					}
				}
				.clipShape(Circle())
		}
		.frame(width: 240, height: 240)
	}
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