import SwiftUI

struct BattleSelectionView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Подготовка к раунду \(gameViewModel.currentRound)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                PlayerSelectionView(player: gameViewModel.player1, playerName: "Игрок 1")
                PlayerSelectionView(player: gameViewModel.player2, playerName: "Игрок 2")
            }
            
            ActionButton(
                title: "Начать раунд",
                action: { gameViewModel.executeRound() },
                isEnabled: areBothPlayersReady()
            )
            
            BattleLogView()
        }
        .padding()
    }
    
    private func areBothPlayersReady() -> Bool {
        return gameViewModel.player1.selectedAttacks.count == 2 &&
               gameViewModel.player1.selectedDefenses.count == 2 &&
               gameViewModel.player2.selectedAttacks.count == 2 &&
               gameViewModel.player2.selectedDefenses.count == 2
    }
}

struct PlayerSelectionView: View {
    @ObservedObject var player: Player
    let playerName: String
    
    var body: some View {
        VStack(spacing: 15) {
            Text("\(playerName): \(player.name)")
                .font(.headline)
                .foregroundColor(.white)
            
            // Атаки
            VStack(alignment: .leading) {
                Text("Атаки (2):")
                    .font(.subheadline)
                    .foregroundColor(.red)
                
                ForEach(AttackType.allCases, id: \.self) { attack in
                    AttackButton(
                        attackType: attack,
                        isSelected: player.selectedAttacks.contains(attack),
                        action: { toggleAttack(attack) }
                    )
                }
            }
            
            // Защиты
            VStack(alignment: .leading) {
                Text("Защиты (2):")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                ForEach(DefenseType.allCases, id: \.self) { defense in
                    DefenseButton(
                        defenseType: defense,
                        isSelected: player.selectedDefenses.contains(defense),
                        action: { toggleDefense(defense) }
                    )
                }
            }
            
            // Статус выбора
            VStack(spacing: 5) {
                if player.selectedAttacks.count == 2 {
                    Text("✅ Атаки выбраны")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Text("Атаки: \(player.selectedAttacks.count)/2")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
                
                if player.selectedDefenses.count == 2 {
                    Text("✅ Защиты выбраны")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Text("Защиты: \(player.selectedDefenses.count)/2")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func toggleAttack(_ attack: AttackType) {
        if player.selectedAttacks.contains(attack) {
            player.selectedAttacks.removeAll { $0 == attack }
        } else if player.selectedAttacks.count < 2 {
            player.selectedAttacks.append(attack)
        }
    }
    
    private func toggleDefense(_ defense: DefenseType) {
        if player.selectedDefenses.contains(defense) {
            player.selectedDefenses.removeAll { $0 == defense }
        } else if player.selectedDefenses.count < 2 {
            player.selectedDefenses.append(defense)
        }
    }
}
