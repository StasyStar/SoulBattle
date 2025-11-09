import SwiftUI

struct BattleView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @State private var animationScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Битва!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Раунд \(gameViewModel.currentRound)")
                .font(.title2)
                .foregroundColor(.white)
            
            HStack(spacing: 30) {
                BattlePlayerView(player: gameViewModel.player1, isAttacker: true)
                VSView()
                BattlePlayerView(player: gameViewModel.player2, isAttacker: false)
            }
            
            // Анимация битвы
            Image(systemName: "burst")
                .font(.system(size: 60))
                .foregroundColor(.orange)
                .scaleEffect(animationScale)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.5).repeatCount(3, autoreverses: true)) {
                        animationScale = 1.5
                    }
                }
            
            BattleLogView()
            
            ActionButton(
                title: "Продолжить",
                action: {
                    if gameViewModel.player1.health <= 0 || gameViewModel.player2.health <= 0 {
                        // Игра завершена
                    } else {
                        gameViewModel.gameState = .selection
                    }
                },
                backgroundColor: .green
            )
        }
        .padding()
        .onAppear {
            // Автоматически продолжаем через 3 секунды
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if gameViewModel.player1.health <= 0 || gameViewModel.player2.health <= 0 {
                    gameViewModel.gameState = .result
                } else {
                    gameViewModel.gameState = .selection
                }
            }
        }
    }
}

struct BattlePlayerView: View {
    @ObservedObject var player: Player
    let isAttacker: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Text(player.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(isAttacker ? .red : .blue)
            
            Text("\(String(format: "%.1f", player.health)) HP")
                .font(.title3)
                .foregroundColor(player.health > 30 ? .green : .red)
            
            HealthBarView(health: player.health, maxHealth: player.maxHealth)
            
            // Показываем выбранные атаки/защиты
            VStack(alignment: .leading, spacing: 5) {
                if isAttacker && !player.selectedAttacks.isEmpty {
                    Text("Атаки:")
                        .font(.caption)
                        .foregroundColor(.white)
                    ForEach(player.selectedAttacks, id: \.self) { attack in
                        HStack {
                            Image(systemName: attack.icon)
                            Text(attack.rawValue)
                                .font(.caption2)
                        }
                        .foregroundColor(.red)
                    }
                }
                
                if !isAttacker && !player.selectedDefenses.isEmpty {
                    Text("Защиты:")
                        .font(.caption)
                        .foregroundColor(.white)
                    ForEach(player.selectedDefenses, id: \.self) { defense in
                        HStack {
                            Image(systemName: defense.icon)
                            Text(defense.rawValue)
                                .font(.caption2)
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}
