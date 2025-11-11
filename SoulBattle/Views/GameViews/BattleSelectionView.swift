import SwiftUI

struct BattleSelectionView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        ScrollView {
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
                .padding(.top, 10) // Уменьшили отступ сверху
                
                // Основной контент
                VStack(spacing: 15) {
                    HStack(alignment: .top, spacing: 12) {
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
                            VStack(spacing: 8) {
                                Text(gameViewModel.player2.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 6) {
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
                                
                                // Информация о характеристиках противника справа под блоком
                                if !gameViewModel.opponentStatsInfo.isEmpty {
                                    VStack(spacing: 6) { // Уменьшили spacing
                                        Text("Характеристики")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        
                                        // Красивый список характеристик
                                        VStack(alignment: .leading, spacing: 2) { // Уменьшили spacing
                                            ForEach(gameViewModel.opponentStatsInfo.components(separatedBy: "\n"), id: \.self) { line in
                                                if !line.isEmpty {
                                                    Text(line)
                                                        .font(.system(size: 11, design: .monospaced)) // Уменьшили шрифт
                                                        .foregroundColor(.white.opacity(0.9))
                                                        .padding(.vertical, 1) // Уменьшили отступы
                                                }
                                            }
                                        }
                                        .padding(6) // Уменьшили padding
                                        .background(Color.orange.opacity(0.2))
                                        .cornerRadius(8)
                                    }
                                    .padding(.top, 5)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    
                    // Для PVP режима показываем информацию о противнике отдельно
                    if gameViewModel.gameMode == .pvp && !gameViewModel.opponentStatsInfo.isEmpty {
                        VStack(spacing: 6) { // Уменьшили spacing
                            Text("Характеристики противника")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            // Красивый список характеристик
                            VStack(alignment: .leading, spacing: 2) { // Уменьшили spacing
                                ForEach(gameViewModel.opponentStatsInfo.components(separatedBy: "\n"), id: \.self) { line in
                                    if !line.isEmpty {
                                        Text(line)
                                            .font(.system(size: 11, design: .monospaced)) // Уменьшили шрифт
                                            .foregroundColor(.white.opacity(0.9))
                                            .padding(.vertical, 1) // Уменьшили отступы
                                    }
                                }
                            }
                            .padding(8)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Улучшенный блок хода битвы
                    ImprovedBattleLogView()
                    
                    // Основные кнопки
                    VStack(spacing: 12) {
                        ActionButton(
                            title: "Начать раунд",
                            action: {
                                gameViewModel.executeRound()
                            },
                            isEnabled: gameViewModel.areSelectionsValid()
                        )
                        
                        // Кнопка "В меню"
                        Button("В меню") {
                            gameViewModel.backToMainMenu()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.9))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    }
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
