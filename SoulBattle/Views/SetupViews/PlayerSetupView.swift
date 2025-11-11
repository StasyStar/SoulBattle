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
                    // Заголовок
                    Text("Начать битву")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    
                    // Приветствие
                    if let character = DataManager.shared.loadCharacter() {
                        VStack(spacing: 8) {
                            // Имя и уровень в одной строке
                            HStack {
                                Text("\(character.name)")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    Text("Уровень \(character.level)")
                                        .font(.headline)
                                        .foregroundColor(.yellow)
                                    
                                    if character.availableStatPoints > 0 {
                                        Text("+\(character.availableStatPoints)")
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
                    
                    // Блок с характеристиками
                    PlayerCardView(
                        player: viewModel.player1,
                        showEditButton: true,
                        onEdit: { showCharacterEditor = true }
                    )
                    .padding(.horizontal)
                    
                    // Правила игры
                    GameRulesView()
                        .padding(.horizontal)
                    
                    // Кнопки
                    VStack(spacing: 12) {
                        ActionButton(
                            title: "Начать битву",
                            action: {
                                viewModel.startGame()
                            },
                            isEnabled: true,
                            backgroundColor: .purple
                        )
                        
                        // Кнопка "В меню"
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
        
        // Случайное отклонение: от -2 до +2 от статов игрока
        let deviation = Int.random(in: -2...2)
        let opponentTotalStats = max(25, playerTotalStats + deviation) // Минимум 25 очков
        
        // Начинаем с 5 очков в каждой характеристике (как у игрока)
        var stats = [5, 5, 5, 5, 5] // Сила, Ловкость, Выносливость, Мудрость, Интеллект
        let basePoints = 25 // 5 * 5 = 25 базовых очков
        
        // Оставшиеся очки для распределения
        var remainingPoints = opponentTotalStats - basePoints
        
        print("=== ГЕНЕРАЦИЯ ПРОТИВНИКА ===")
        print("Статы игрока: \(playerTotalStats)")
        print("Отклонение: \(deviation)")
        print("Всего очков противника: \(opponentTotalStats)")
        print("Базовые очки: \(basePoints)")
        print("Осталось распределить: \(remainingPoints)")
        
        // Распределяем оставшиеся очки случайным образом
        while remainingPoints > 0 {
            let randomIndex = Int.random(in: 0..<5)
            stats[randomIndex] += 1
            remainingPoints -= 1
        }
        
        // Перемешиваем статы для разнообразия
        stats.shuffle()
        
        // Обновляем противника
        viewModel.player2.strength = stats[0]
        viewModel.player2.agility = stats[1]
        viewModel.player2.endurance = stats[2]
        viewModel.player2.wisdom = stats[3]
        viewModel.player2.intellect = stats[4]
        
        // Сохраняем информацию о противнике для отображения в битве
        let opponentName = getRandomAIName()
        viewModel.player2.name = opponentName
        
        // Формируем красивый список характеристик
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
    
    private func getRandomAIName() -> String {
        let names = ["Морфей", "Зефир", "Игнис", "Астра", "Нексус", "Оракул", "Феникс", "Темпус", "Люмен", "Хронос", "Вортигон", "Арканум"]
        return names.randomElement() ?? "Соперник"
    }
}

// Структура для карточки игрока
struct PlayerCardView: View {
    @ObservedObject var player: Player
    let showEditButton: Bool
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Заголовок с кнопкой редактирования
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
            
            // Здоровье на одной строке со шкалой
            HStack {
                Text("❤️ Здоровье")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Шкала здоровья с текстом прямо на ней
                ZStack(alignment: .trailing) {
                    // Фон шкалы
                    Rectangle()
                        .frame(width: 120, height: 20)
                        .opacity(0.3)
                        .foregroundColor(.red)
                        .cornerRadius(10)
                    
                    // Заполненная часть шкалы
                    Rectangle()
                        .frame(width: CGFloat(player.health / player.maxHealth * 120), height: 20)
                        .foregroundColor(player.health > 30 ? .green : .red)
                        .cornerRadius(10)
                    
                    // Текст здоровья прямо на шкале
                    Text("\(Int(player.health))/\(Int(player.maxHealth))")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                }
            }
            .padding(.bottom, 5)
            
            // Характеристики
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

// Структура для отображения статистики
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

// Структура для правил игры
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
            
            // Типы атак и защит
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

// Структура для элемента правила
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
