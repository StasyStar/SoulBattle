import SwiftUI

struct BattleSelectionView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                // Заголовок
                VStack {
                    Text("Подготовка к раунду \(gameViewModel.currentRound)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Режим: \(getGameModeDescription())")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 5)
                
                // Основной контент
                VStack(spacing: 12) {
                    HStack(alignment: .top, spacing: 10) {
                        // Игрок 1
                        PlayerSelectionView(
                            player: gameViewModel.player1,
                            playerName: gameViewModel.player1.name,
                            isInteractive: true,
                            gameViewModel: gameViewModel
                        )
                        
                        // Игрок 2 / Компьютер
                        if gameViewModel.gameMode == .pvp {
                            PlayerSelectionView(
                                player: gameViewModel.player2,
                                playerName: gameViewModel.player2.name,
                                isInteractive: true,
                                gameViewModel: gameViewModel
                            )
                        } else {
                            AIPlayerView()
                        }
                    }
                    
                    // Информация о противнике для PVP
                    if gameViewModel.gameMode == .pvp && !gameViewModel.opponentStatsInfo.isEmpty {
                        OpponentStatsView()
                    }
                    
                    // Лог битвы с HP
                    ImprovedBattleLogView()
                    
                    // Кнопки действий
                    ActionButtonsView()
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
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

// Вспомогательные View для лучшей организации кода
struct AIPlayerView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 6) {
            Text(gameViewModel.player2.name)
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 4) {
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
            
            if !gameViewModel.opponentStatsInfo.isEmpty {
                VStack(spacing: 4) {
                    Text("Характеристики")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 1) {
                        ForEach(gameViewModel.opponentStatsInfo.components(separatedBy: "\n"), id: \.self) { line in
                            if !line.isEmpty {
                                Text(line)
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.vertical, 0.5)
                            }
                        }
                    }
                    .padding(4)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(6)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

struct OpponentStatsView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Характеристики противника")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 1) {
                ForEach(gameViewModel.opponentStatsInfo.components(separatedBy: "\n"), id: \.self) { line in
                    if !line.isEmpty {
                        Text(line)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.vertical, 0.5)
                    }
                }
            }
            .padding(6)
            .background(Color.orange.opacity(0.2))
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }
}

struct ActionButtonsView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            ActionButton(
                title: "Начать раунд",
                action: {
                    gameViewModel.executeRound()
                },
                isEnabled: gameViewModel.areSelectionsValid(),
                backgroundColor: .blue,
                size: .small
            )
            
            Button("В меню") {
                gameViewModel.backToMainMenu()
            }
            .font(.subheadline)
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color.orange.opacity(0.9))
            .cornerRadius(12)
            .shadow(radius: 3)
            .padding(.horizontal)
        }
        .padding(.top, 5)
    }
}
