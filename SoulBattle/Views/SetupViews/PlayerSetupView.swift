import SwiftUI

struct PlayerSetupView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var showCharacterEditor = false
    
    var body: some View {
        ZStack {
            // Фон
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Начать битву")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    
                    if let character = DataManager.shared.loadCharacter() {
                        VStack(spacing: 8) {
                            HStack {
                                Text("\(character.name)")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    Text("Уровень \(character.level)")
                                        .font(.headline)
                                        .foregroundColor(.yellow)
                                    
                                    if character.totalBonusPoints > 0 {
                                        Text("+\(character.totalBonusPoints)")
                                            .font(.headline)
                                            .foregroundColor(.green)
                                            .padding(4)
                                            .background(Color.green.opacity(0.3))
                                            .cornerRadius(4)
                                    }
                                }
                            }
                            
                            Text("Проверь свои характеристики перед боем")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                        .background(Color.purple.opacity(0.3))
                        .cornerRadius(12)
                    }
                    
                    PlayerCardView(
                        player: viewModel.player1,
                        showEditButton: true,
                        onEdit: { showCharacterEditor = true }
                    )
                    .padding(.horizontal)
                    
                    GameRulesView()
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        ActionButton(
                            title: "Начать битву",
                            action: {
                                viewModel.startGame()
                            },
                            isEnabled: true,
                            backgroundColor: .purple
                        )
                        
                        Button("В меню") {
                            viewModel.backToMainMenu()
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
                    
                    Spacer()
                }
                .padding()
            }
        }
        .sheet(isPresented: $showCharacterEditor) {
            CharacterCreationView(isRegistration: false)
        }
        .onAppear {
            generateOpponentStats()
        }
    }
    
    private func generateOpponentStats() {
        guard let playerCharacter = DataManager.shared.loadCharacter() else { return }
        
        let playerTotalStats = playerCharacter.strength + playerCharacter.agility +
                              playerCharacter.endurance + playerCharacter.wisdom +
                              playerCharacter.intellect
        
        let deviation = Int.random(in: -2...2)
        let opponentTotalStats = max(GameConstants.Balance.baseStatPoints, playerTotalStats + deviation)
        
        var stats = [5, 5, 5, 5, 5]
        let basePoints = GameConstants.Balance.baseStatPoints
        
        var remainingPoints = opponentTotalStats - basePoints
        
        print("=== ГЕНЕРАЦИЯ ПРОТИВНИКА ===")
        print("Статы игрока: \(playerTotalStats)")
        print("Отклонение: \(deviation)")
        print("Всего очков противника: \(opponentTotalStats)")
        print("Базовые очки: \(basePoints)")
        print("Осталось распределить: \(remainingPoints)")
        
        while remainingPoints > 0 {
            let randomIndex = Int.random(in: 0..<5)
            stats[randomIndex] += 1
            remainingPoints -= 1
        }
        
        stats.shuffle()
        
        viewModel.player2.strength = stats[0]
        viewModel.player2.agility = stats[1]
        viewModel.player2.endurance = stats[2]
        viewModel.player2.wisdom = stats[3]
        viewModel.player2.intellect = stats[4]
        
        let opponentName = GameConstants.getRandomAIName()
        viewModel.player2.name = opponentName
        
        let statsList = """
        💪 Сила: \(stats[0])
        🏃 Ловкость: \(stats[1])
        ❤️ Выносливость: \(stats[2])
        📚 Мудрость: \(stats[3])
        🧠 Интеллект: \(stats[4])
        """
        
        viewModel.opponentStatsInfo = statsList
        
        print("Сгенерирован противник: \(opponentName)")
        print("Характеристики: \(statsList)")
    }
}

// MARK: - PlayerCardView
struct PlayerCardView: View {
    @ObservedObject var player: Player
    let showEditButton: Bool
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Ваш персонаж")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                if showEditButton {
                    Button(action: onEdit) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
            }
            
            HStack {
                Text("❤️ Здоровье")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
                
                ZStack(alignment: .trailing) {
                    Rectangle()
                        .frame(width: 120, height: 20)
                        .opacity(0.3)
                        .foregroundColor(.red)
                        .cornerRadius(10)
                    
                    Rectangle()
                        .frame(width: CGFloat(player.health / player.maxHealth * 120), height: 20)
                        .foregroundColor(player.health > 30 ? .green : .red)
                        .cornerRadius(10)
                    
                    Text("\(Int(player.health))/\(Int(player.maxHealth))")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                }
            }
            .padding(.bottom, 5)
            
            VStack(spacing: 10) {
                StatView(name: "💪 Сила", value: player.strength, color: .red)
                StatView(name: "🏃 Ловкость", value: player.agility, color: .green)
                StatView(name: "❤️ Выносливость", value: player.endurance, color: .orange)
                StatView(name: "📚 Мудрость", value: player.wisdom, color: .blue)
                StatView(name: "🧠 Интеллект", value: player.intellect, color: .purple)
            }
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(15)
    }
}

// MARK: - StatView
struct StatView: View {
    let name: String
    let value: Int
    let color: Color
    
    var body: some View {
        HStack {
            Text(name)
                .font(.subheadline)
                .foregroundColor(.white)
            Spacer()
            Text("\(value)")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(8)
        .background(color.opacity(0.3))
        .cornerRadius(8)
    }
}

// MARK: - GameRulesView
struct GameRulesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Правила битвы")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 12) {
                RuleItem(icon: "🎯", text: "Выбери 2 атаки и 2 защиты")
                RuleItem(icon: "⚔️", text: "Атаки наносят урон противнику")
                RuleItem(icon: "🛡️", text: "Защиты блокируют урон")
                RuleItem(icon: "❤️", text: "Победит тот, у кого останется здоровье")
                RuleItem(icon: "🏆", text: "Победа приносит опыт и статистику")
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Типы способностей:")
                    .font(.headline)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• 🔥 Огненная атака/защита")
                    Text("• ⚡️ Атака/защита молнией")
                    Text("• 🗡️ Атака/защита оружием")
                    Text("• 💧 Кислотная атака/защита")
                    Text("• 🧠 Психо-атака/защита")
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(15)
    }
}

// MARK: - RuleItem
struct RuleItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(icon)
                .font(.title3)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}
