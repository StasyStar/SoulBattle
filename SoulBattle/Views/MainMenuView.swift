import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            // Приветствие с именем игрока
            VStack(spacing: 10) {
                Text("Soul Battle")
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .purple, radius: 10)
                
                if let character = DataManager.shared.loadCharacter() {
                    Text("Добро пожаловать, \(character.name)!")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Статистика персонажа
                    VStack(spacing: 5) {
                        Text("Ваша статистика:")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Победы: \(character.battlesWon)")
                                Text("Поражения: \(character.battlesLost)")
                            }
                            VStack(alignment: .leading) {
                                Text("Урон: \(String(format: "%.0f", character.totalDamageDealt))")
                                Text("Получено: \(String(format: "%.0f", character.totalDamageTaken))")
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        
                        Text("Процент побед: \(String(format: "%.1f", character.winRate))%")
                            .font(.caption)
                            .foregroundColor(character.winRate > 50 ? .green : .orange)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            
            VStack(spacing: 20) {
                MenuButton(
                    title: "Игрок vs Игрок",
                    subtitle: "Сразитесь с другом",
                    icon: "person.2",
                    color: .blue,
                    action: { viewModel.startPVPGame() }
                )
                
                MenuButton(
                    title: "Игрок vs Компьютер",
                    subtitle: "Бой против ИИ",
                    icon: "desktopcomputer",
                    color: .green,
                    action: { viewModel.startPVEGame() }
                )
                
                // Кнопка создания нового персонажа
                Button("Создать нового персонажа") {
                    viewModel.gameState = .characterCreation
                }
                .buttonStyle(.bordered)
                .tint(.orange)
            }
            
            // Статистика последней игры
            if !viewModel.gameLog.isEmpty {
                VStack {
                    Text("Последняя игра:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(viewModel.gameLog.last ?? "")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding()
    }
}
