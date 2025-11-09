import SwiftUI

struct BattleLogView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Ход битвы:")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 5) {
                    ForEach(gameViewModel.gameLog.suffix(10), id: \.self) { logEntry in
                        Text(logEntry)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(2)
                    }
                }
            }
            .frame(height: 120)
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(8)
        }
    }
}
