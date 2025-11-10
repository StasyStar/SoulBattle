import SwiftUI

struct GameResultView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Битва завершена!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Результат
            if gameViewModel.player1.health <= 0 && gameViewModel.player2.health <= 0 {
                Text("НИЧЬЯ!")
                    .font(.title)
                    .foregroundColor(.yellow)
            } else if gameViewModel.player1.health <= 0 {
                WinnerView(player: gameViewModel.player2)
            } else {
                WinnerView(player: gameViewModel.player1)
            }
            
            // Статистика игроков
            HStack(spacing: 20) {
                PlayerStatsView(player: gameViewModel.player1)
                PlayerStatsView(player: gameViewModel.player2)
            }
            
            // Статистика персонажа (если есть сохраненный персонаж)
            if let character = DataManager.shared.loadCharacter() {
                VStack(spacing: 15) {
                    Text("Ваша статистика")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 30) {
                        VStack(spacing: 5) {
                            Text("Победы")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text("\(character.battlesWon)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        
                        VStack(spacing: 5) {
                            Text("Поражения")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text("\(character.battlesLost)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                        
                        VStack(spacing: 5) {
                            Text("Побед %")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text("\(String(format: "%.1f", character.winRate))%")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(character.winRate > 50 ? .green : .orange)
                        }
                    }
                    
                    HStack(spacing: 30) {
                        VStack(spacing: 5) {
                            Text("Всего урона")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text("\(String(format: "%.0f", character.totalDamageDealt))")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                        
                        VStack(spacing: 5) {
                            Text("Получено")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text("\(String(format: "%.0f", character.totalDamageTaken))")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
            }
            
            // Итоговый лог
            GameResultLogView()
            
            // Кнопки действий
            VStack(spacing: 15) {
                ActionButton(
                    title: "Новая игра",
                    action: {
                        gameViewModel.resetGame()
                        gameViewModel.gameState = .selection
                    },
                    backgroundColor: .green
                )
                
                ActionButton(
                    title: "В главное меню",
                    action: {
                        gameViewModel.backToMainMenu()
                    },
                    backgroundColor: .blue
                )
            }
        }
        .padding()
    }
}

struct WinnerView: View {
    let player: Player
    
    var body: some View {
        VStack(spacing: 10) {
            Text("ПОБЕДИТЕЛЬ")
                .font(.title2)
                .fontWeight(.black)
                .foregroundColor(.yellow)
            
            Text(player.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            Text("Осталось энергии: \(String(format: "%.1f", player.health))")
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.green.opacity(0.2))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.yellow, lineWidth: 3)
        )
    }
}

struct PlayerStatsView: View {
    let player: Player
    
    var body: some View {
        VStack(spacing: 10) {
            Text(player.name)
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Энергия: \(String(format: "%.1f", player.health))")
                    .font(.caption)
                    .foregroundColor(player.health > 0 ? .green : .red)
                
                Text("Нанесено урона: \(String(format: "%.1f", player.damageDealt))")
                    .font(.caption)
                    .foregroundColor(.red)
                
                Text("Получено урона: \(String(format: "%.1f", player.damageTaken))")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Text("Побед в раундах: \(player.roundsWon)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

struct GameResultLogView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("История битвы:")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 3) {
                    ForEach(gameViewModel.gameLog, id: \.self) { logEntry in
                        Text(logEntry)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(2)
                    }
                }
            }
            .frame(height: 150)
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(8)
        }
    }
}
