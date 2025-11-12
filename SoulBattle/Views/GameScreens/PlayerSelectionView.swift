import SwiftUI

struct PlayerSelectionView: View {
    @ObservedObject var player: Player
    let playerName: String
    let isInteractive: Bool
    let gameViewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 6) {
                Text(playerName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                VStack(spacing: 3) {
                    Text("\(String(format: "%.0f", player.health))/\(String(format: "%.0f", player.maxHealth)) HP")
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    HealthBarView(health: player.health, maxHealth: player.maxHealth)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Атаки (\(player.selectedAttacks.count)/2)")
                        .font(.subheadline)
                        .foregroundColor(.red)
                    
                    Spacer()
                }
                
                ForEach(AttackType.allCases, id: \.self) { attack in
                    CompactAttackButton(
                        attackType: attack,
                        isSelected: player.selectedAttacks.contains(attack),
                        action: { toggleAttack(attack) }
                    )
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Защиты (\(player.selectedDefenses.count)/2)")
                        .font(.subheadline)
                        .foregroundColor(Color.blue.opacity(0.9)) // Более темный синий
                    
                    Spacer()
                }
                
                ForEach(DefenseType.allCases, id: \.self) { defense in
                    CompactDefenseButton(
                        defenseType: defense,
                        isSelected: player.selectedDefenses.contains(defense),
                        action: { toggleDefense(defense) }
                    )
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func toggleAttack(_ attack: AttackType) {
        if player.selectedAttacks.contains(attack) {
            player.selectedAttacks.removeAll { $0 == attack }
        } else if player.selectedAttacks.count < 2 {
            player.selectedAttacks.append(attack)
        }
        
        gameViewModel.forceUpdate()
    }
    
    private func toggleDefense(_ defense: DefenseType) {
        if player.selectedDefenses.contains(defense) {
            player.selectedDefenses.removeAll { $0 == defense }
        } else if player.selectedDefenses.count < 2 {
            player.selectedDefenses.append(defense)
        }
        
        gameViewModel.forceUpdate()
    }
}
