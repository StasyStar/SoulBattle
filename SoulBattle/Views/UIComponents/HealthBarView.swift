import SwiftUI

struct HealthBarView: View {
    let health: Double
    let maxHealth: Double
    
    var body: some View {
        VStack {
            Text("\(String(format: "%.1f", health))/\(String(format: "%.0f", maxHealth))")
                .font(.caption)
                .foregroundColor(.white)
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: 100, height: 10)
                    .opacity(0.3)
                    .foregroundColor(.red)
                
                Rectangle()
                    .frame(width: CGFloat(health / maxHealth * 100), height: 10)
                    .foregroundColor(health > 30 ? .green : .red)
                    .animation(.easeInOut, value: health)
            }
            .cornerRadius(5)
        }
    }
}
