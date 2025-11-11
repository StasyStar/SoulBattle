import SwiftUI

struct ImprovedBattleLogView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Ход битвы:")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(gameViewModel.gameLog.suffix(15), id: \.self) { logEntry in
                        // Пропускаем строку о начале игры
                        if !logEntry.contains("Игра началась!") && !logEntry.contains("против") {
                            Text(logEntry)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                        }
                    }
                }
            }
            .frame(height: 100) // Увеличили высоту для лучшей читаемости
            .padding(8)
            .background(Color.black.opacity(0.3))
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }
}
