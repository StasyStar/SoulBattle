import SwiftUI

struct BattleSelectionView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Заголовок с информацией о режиме
            VStack {
                Text("Подготовка к раунду \(gameViewModel.currentRound)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Режим: \(getGameModeDescription())")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            HStack(spacing: 20) {
                // Игрок 1
                PlayerSelectionView(
                    player: gameViewModel.player1,
                    playerName: gameViewModel.gameMode == .pvp ? "Игрок 1" : "Игрок",
                    isInteractive: true,
                    gameViewModel: gameViewModel
                )
                
                // Игрок 2 / Компьютер
                if gameViewModel.gameMode == .pvp {
                    PlayerSelectionView(
                        player: gameViewModel.player2,
                        playerName: "Игрок 2",
                        isInteractive: true,
                        gameViewModel: gameViewModel
                    )
                } else {
                    VStack(spacing: 15) {
                        Text("Компьютер")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 10) {
                            Image(systemName: "desktopcomputer")
                                .font(.title2)
                                .foregroundColor(.green)
                            
                            Text("Готов к бою!")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Text("Выборы сделаны автоматически")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            
            // Основные кнопки
            HStack {
                Button("В меню") {
                    gameViewModel.backToMainMenu()
                }
                .buttonStyle(.bordered)
                .tint(.gray)
                
                Spacer()
                
                ActionButton(
                    title: "Начать раунд",
                    action: {
                        gameViewModel.executeRound()
                    },
                    isEnabled: gameViewModel.areSelectionsValid()
                )
            }
            
            BattleLogView()
        }
        .padding()
        .onAppear {
            gameViewModel.forceUpdate()
        }
    }
    
    private func getGameModeDescription() -> String {
        switch gameViewModel.gameMode {
        case .pvp: return "Игрок vs Игрок"
        case .pve: return "Игрок vs Компьютер"
        }
    }
}
