import SwiftUI

struct PlayerSelectionView: View {
    @ObservedObject var player: Player
    let playerName: String
    let isInteractive: Bool
    let gameViewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            Text("\(playerName)")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Здоровье: \(String(format: "%.1f", player.health))")
                .font(.caption)
                .foregroundColor(.white)
            
            // Атаки
            VStack(alignment: .leading) {
                Text("Атаки (2):")
                    .font(.subheadline)
                    .foregroundColor(.red)
                
                ForEach(AttackType.allCases, id: \.self) { attack in
                    Button(action: {
                        toggleAttack(attack)
                    }) {
                        HStack {
                            Image(systemName: attack.icon)
                            Text(attack.rawValue)
                                .font(.caption)
                            Spacer()
                            if player.selectedAttacks.contains(attack) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(10)
                        .background(player.selectedAttacks.contains(attack) ? Color.red.opacity(0.3) : Color.gray.opacity(0.2))
                        .foregroundColor(player.selectedAttacks.contains(attack) ? .red : .primary)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(player.selectedAttacks.contains(attack) ? Color.red : Color.gray, lineWidth: 1)
                        )
                    }
                }
            }
            
            // Защиты
            VStack(alignment: .leading) {
                Text("Защиты (2):")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                ForEach(DefenseType.allCases, id: \.self) { defense in
                    Button(action: {
                        toggleDefense(defense)
                    }) {
                        HStack {
                            Image(systemName: defense.icon)
                            Text(defense.rawValue)
                                .font(.caption)
                            Spacer()
                            if player.selectedDefenses.contains(defense) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(10)
                        .background(player.selectedDefenses.contains(defense) ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                        .foregroundColor(player.selectedDefenses.contains(defense) ? .blue : .primary)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(player.selectedDefenses.contains(defense) ? Color.blue : Color.gray, lineWidth: 1)
                        )
                    }
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
