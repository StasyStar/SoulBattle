import SwiftUI

struct BattleView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @State private var animationScale: CGFloat = 1.0
    @State private var showDetails = false
    
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
            
            // Детали раунда
            if let details = gameViewModel.roundDetails {
                RoundDetailsView(details: details, gameMode: gameViewModel.gameMode)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
            }
            
            BattleLogView()
            
            ActionButton(
                title: "Продолжить",
                action: {
                    if gameViewModel.player1.health <= 0 || gameViewModel.player2.health <= 0 {
                        gameViewModel.gameState = .result
                    } else {
                        gameViewModel.gameState = .selection
                    }
                },
                backgroundColor: .green
            )
        }
        .padding()
        .onAppear {
            // Автоматически продолжаем через 4 секунды (чтобы успеть прочитать детали)
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                if gameViewModel.player1.health <= 0 || gameViewModel.player2.health <= 0 {
                    gameViewModel.gameState = .result
                } else {
                    gameViewModel.gameState = .selection
                }
            }
        }
    }
}

struct RoundDetailsView: View {
    let details: RoundDetails
    let gameMode: GameMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Результаты раунда \(details.roundNumber)")
                .font(.headline)
                .foregroundColor(.white)
            
            // Игрок 1
            VStack(alignment: .leading, spacing: 5) {
                Text("Игрок:")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Атаки: \(details.player1Attacks.map { $0.rawValue }.joined(separator: ", "))")
                        Text("Защиты: \(details.player1Defenses.map { $0.rawValue }.joined(separator: ", "))")
                        Text("Нанесено урона: \(String(format: "%.1f", details.player1DamageDealt))")
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Осталось HP:")
                            .fontWeight(.bold)
                        Text("\(String(format: "%.1f", details.player1HealthAfter))")
                            .foregroundColor(details.player1HealthAfter > 30 ? .green : .red)
                    }
                }
                .font(.caption)
                .foregroundColor(.white)
            }
            
            // Игрок 2/Компьютер
            VStack(alignment: .leading, spacing: 5) {
                Text(gameMode == .pvp ? "Игрок 2:" : "Компьютер:")
                    .font(.subheadline)
                    .foregroundColor(.red)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Атаки: \(details.player2Attacks.map { $0.rawValue }.joined(separator: ", "))")
                        Text("Защиты: \(details.player2Defenses.map { $0.rawValue }.joined(separator: ", "))")
                        Text("Нанесено урона: \(String(format: "%.1f", details.player2DamageDealt))")
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Осталось HP:")
                            .fontWeight(.bold)
                        Text("\(String(format: "%.1f", details.player2HealthAfter))")
                            .foregroundColor(details.player2HealthAfter > 30 ? .green : .red)
                    }
                }
                .font(.caption)
                .foregroundColor(.white)
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
                .foregroundColor(isAttacker ? .blue : .red)
            
            Text("\(String(format: "%.1f", player.health)) HP")
                .font(.title3)
                .foregroundColor(player.health > 30 ? .green : .red)
            
            HealthBarView(health: player.health, maxHealth: player.maxHealth)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}
