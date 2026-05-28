import SwiftUI

// MARK: - Color Palette
extension Color {
    // Surfaces
    static let upBackground = Color(hex: "111317")
    static let upSurface = Color(hex: "1e2024")
    static let upSurfaceHigh = Color(hex: "282a2e")
    static let upSurfaceHighest = Color(hex: "333539")
    static let upSurfaceLowest = Color(hex: "0c0e12")

    // Brand
    static let upPrimary       = Color(hex: "00f0ff")   // Electric cyan
    static let upPrimaryDim    = Color(hex: "00dbe9")
    static let upPrimaryText   = Color(hex: "dbfcff")
    static let upSecondary     = Color(hex: "36ffc4")   // Mint green
    static let upSecondaryDim  = Color(hex: "00e1ab")
    static let upTertiary      = Color(hex: "7213ff")   // Violet
    // Text
    static let upTextPrimary   = Color(hex: "e2e2e8")
    static let upTextSecondary = Color(hex: "b9cacb")
    static let upOutline       = Color(hex: "849495")
    static let upOutlineVariant = Color(hex: "3b494b")
    // Semantic
    static let upError         = Color(hex: "ffb4ab")
    static let upSuccess       = Color(hex: "36ffc4")

    // Hex initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// MARK: - Glass Card ViewModifier
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var glowColor: Color = .clear

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: glowColor.opacity(0.3), radius: 20, x: 0, y: 0)
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 16, glowColor: Color = .clear) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, glowColor: glowColor))
    }
}

// MARK: - Neon Glow ViewModifier
struct NeonGlowModifier: ViewModifier {
    var color: Color = .upPrimary
    var radius: CGFloat = 12

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.7), radius: radius / 2)
            .shadow(color: color.opacity(0.4), radius: radius)
    }
}

extension View {
    func neonGlow(color: Color = .upPrimary, radius: CGFloat = 12) -> some View {
        modifier(NeonGlowModifier(color: color, radius: radius))
    }
}

// MARK: - Glowing Dot
struct GlowingDot: View {
    var color: Color
    var size: CGFloat = 8
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: size * 2.5, height: size * 2.5)
                .scaleEffect(pulse ? 1.3 : 1.0)
                .opacity(pulse ? 0 : 0.6)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: pulse)
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .shadow(color: color.opacity(0.8), radius: 4)
        }
        .onAppear { pulse = true }
    }
}

// MARK: - UniPark Nav Bar Style
struct UniParkNavBarAppearance {
    static func apply() {
        // Called from App entry point - configures global dark appearance
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.upPrimaryText)
        ]
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor(Color.upPrimaryText)
        ]
        UITabBar.appearance().barTintColor = UIColor(Color.upSurfaceLowest)
        UITabBar.appearance().backgroundColor = UIColor(Color.upSurfaceLowest)
    }
}
