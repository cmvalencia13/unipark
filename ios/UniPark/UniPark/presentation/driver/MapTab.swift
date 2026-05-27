import SwiftUI

public struct MapTab: View {
    @State var viewModel: DriverViewModel
    
    public init(viewModel: DriverViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            Color.upBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                UniParkHeader {
                    NotificationCenter.default.post(name: Notification.Name("signOut"), object: nil)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 80, weight: .semibold))
                        .foregroundStyle(Color.upSurfaceHighest)
                    
                    Text("Mapa en desarrollo")
                        .font(.title2)
                        .foregroundStyle(Color.upTextSecondary)
                    
                    Text("Disponible próximamente")
                        .font(.subheadline)
                        .foregroundStyle(Color.upTextSecondary)
                }
                .multilineTextAlignment(.center)
                
                Spacer()
            }
        }
    }
}
