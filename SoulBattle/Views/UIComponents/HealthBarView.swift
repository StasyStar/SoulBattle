import SwiftUI

struct HealthBarView: View {
    let health: Double
    let maxHealth: Double
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: 120, height: 12)
                    .opacity(0.3)
                    .foregroundColor(.red)
                
                Rectangle()
                    .frame(width: CGFloat(health / maxHealth * 120), height: 12)
                    .foregroundColor(health > 30 ? .green : .red)
                    .animation(.easeInOut, value: health)
            }
            .cornerRadius(6)
        }
    }
}
