import SwiftUI

public struct UniParkHeader: View {
    let onSignOut: () -> Void
    
    public init(onSignOut: @escaping () -> Void) {
        self.onSignOut = onSignOut
    }
    
    public var body: some View {
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
                    .foregroundStyle(Color.upTextSecondary)
                    .padding(10)
                    .background(Color.upSurfaceHighest)
                    .clipShape(Circle())
            }
            
            Button(action: onSignOut) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.title3)
                    .foregroundStyle(Color.upTextSecondary)
                    .padding(10)
                    .background(Color.upSurfaceHighest)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
