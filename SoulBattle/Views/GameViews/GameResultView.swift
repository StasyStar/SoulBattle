import SwiftUI

struct GameResultView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @State private var opponentName: String = ""
    
    // Вычисляемые свойства для статистики
    private var battleStatistics: BattleStatistics {
        return calculateBattleStatistics()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Добавляем отступ сверху
                Spacer().frame(height: 20)
                
                Text("Битва завершена!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Результат - используем информацию из истории битвы
                if battleStatistics.isDraw {
                    Text("НИЧЬЯ!")
                        .font(.title)
                        .foregroundColor(.yellow)
                } else if let winner = battleStatistics.winner {
                    WinnerView(player: winner)
                }
                
                // Статистика игроков
                HStack(spacing: 20) {
                    PlayerStatsView(
                        player: gameViewModel.player1,
                        isPlayer: true,
                        statistics: battleStatistics
                    )
                    PlayerStatsView(
                        player: gameViewModel.player2,
                        isPlayer: false,
                        statistics: battleStatistics
                    )
                }
                
                // Статистика персонажа (если есть сохраненный персонаж)
                if let character = DataManager.shared.loadCharacter() {
                    CharacterStatisticsView(character: character)
                }
                
                // Итоговый лог
                GameResultLogView()
                
                // Кнопки действий
                GameResultActionButtons()
                
                // Добавляем отступ снизу для скролла
                Spacer().frame(height: 20)
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
            generateNewOpponentInfo()
            print("Рассчитанная статистика:")
            print("Игрок 1 - Урон: \(battleStatistics.player1DamageDealt), Получено: \(battleStatistics.player1DamageTaken), Побед в раундах: \(battleStatistics.player1RoundsWon)")
            print("Игрок 2 - Урон: \(battleStatistics.player2DamageDealt), Получено: \(battleStatistics.player2DamageTaken), Побед в раундах: \(battleStatistics.player2RoundsWon)")
        }
    }
    
    // Структура для хранения статистики битвы
    struct BattleStatistics {
        let player1DamageDealt: Double
        let player1DamageTaken: Double
        let player2DamageDealt: Double
        let player2DamageTaken: Double
        let player1RoundsWon: Int
        let player2RoundsWon: Int
        let totalRounds: Int
        let winner: Player?
        let isDraw: Bool
        let player1FinalHealth: Double
        let player2FinalHealth: Double
    }
    
    // Основной метод расчета статистики из логов
    private func calculateBattleStatistics() -> BattleStatistics {
        var player1DamageDealt: Double = 0
        var player1DamageTaken: Double = 0
        var player2DamageDealt: Double = 0
        var player2DamageTaken: Double = 0
        var player1RoundsWon: Int = 0
        var player2RoundsWon: Int = 0
        var totalRounds: Int = 0
        var player1FinalHealth: Double = gameViewModel.player1.maxHealth
        var player2FinalHealth: Double = gameViewModel.player2.maxHealth
        
        // Анализируем каждый раунд из лога
        var currentRound = 0
        var roundDamagePlayer1: Double = 0
        var roundDamagePlayer2: Double = 0
        
        for logEntry in gameViewModel.gameLog {
            // Определяем начало раунда
            if logEntry.contains("=== Раунд") {
                if currentRound > 0 {
                    // Определяем победителя предыдущего раунда
                    if roundDamagePlayer1 > roundDamagePlayer2 {
                        player1RoundsWon += 1
                    } else if roundDamagePlayer2 > roundDamagePlayer1 {
                        player2RoundsWon += 1
                    }
                    // Если урон равен - никто не побеждает
                }
                currentRound += 1
                roundDamagePlayer1 = 0
                roundDamagePlayer2 = 0
                continue
            }
            
            // Анализируем урон игрока 1
            if logEntry.contains(gameViewModel.player1.name) && logEntry.contains("нанес") && logEntry.contains("урона") {
                if let damage = extractDamageFromLog(logEntry) {
                    player1DamageDealt += damage
                    roundDamagePlayer1 += damage
                    player2DamageTaken += damage
                }
            }
            
            // Анализируем урон игрока 2
            if logEntry.contains(gameViewModel.player2.name) && logEntry.contains("нанес") && logEntry.contains("урона") {
                if let damage = extractDamageFromLog(logEntry) {
                    player2DamageDealt += damage
                    roundDamagePlayer2 += damage
                    player1DamageTaken += damage
                }
            }
            
            // Анализируем HP игроков
            if logEntry.contains("HP") && logEntry.contains(":") {
                if let (playerName, health) = extractHealthFromLog(logEntry) {
                    if playerName == gameViewModel.player1.name {
                        player1FinalHealth = health
                    } else if playerName == gameViewModel.player2.name {
                        player2FinalHealth = health
                    }
                }
            }
        }
        
        // Обрабатываем последний раунд
        if currentRound > 0 {
            if roundDamagePlayer1 > roundDamagePlayer2 {
                player1RoundsWon += 1
            } else if roundDamagePlayer2 > roundDamagePlayer1 {
                player2RoundsWon += 1
            }
        }
        
        totalRounds = currentRound
        
        // Определяем победителя битвы
        let (winner, isDraw) = determineWinner(
            player1Health: player1FinalHealth,
            player2Health: player2FinalHealth
        )
        
        return BattleStatistics(
            player1DamageDealt: player1DamageDealt,
            player1DamageTaken: player1DamageTaken,
            player2DamageDealt: player2DamageDealt,
            player2DamageTaken: player2DamageTaken,
            player1RoundsWon: player1RoundsWon,
            player2RoundsWon: player2RoundsWon,
            totalRounds: totalRounds,
            winner: winner,
            isDraw: isDraw,
            player1FinalHealth: player1FinalHealth,
            player2FinalHealth: player2FinalHealth
        )
    }
    
    // Извлекаем урон из строки лога
    private func extractDamageFromLog(_ logEntry: String) -> Double? {
        let components = logEntry.components(separatedBy: " ")
        for component in components {
            if let damage = Double(component) {
                return damage
            }
        }
        return nil
    }
    
    // Извлекаем HP из строки лога
    private func extractHealthFromLog(_ logEntry: String) -> (playerName: String, health: Double)? {
        let components = logEntry.components(separatedBy: ":")
        guard components.count >= 2 else { return nil }
        
        let playerName = components[0].trimmingCharacters(in: .whitespaces)
        let healthString = components[1].trimmingCharacters(in: .whitespaces).components(separatedBy: " ")[0]
        
        if let health = Double(healthString) {
            return (playerName, health)
        }
        return nil
    }
    
    // Определяем победителя битвы
    private func determineWinner(player1Health: Double, player2Health: Double) -> (winner: Player?, isDraw: Bool) {
        if player1Health <= 0 && player2Health <= 0 {
            return (nil, true) // Ничья - оба мертвы
        } else if player1Health > 0 && player2Health <= 0 {
            return (gameViewModel.player1, false) // Победил игрок 1
        } else if player2Health > 0 && player1Health <= 0 {
            return (gameViewModel.player2, false) // Победил игрок 2
        } else {
            // Оба живы - победитель по HP
            return player1Health > player2Health ?
                (gameViewModel.player1, false) :
                (gameViewModel.player2, false)
        }
    }
    
    private func generateNewOpponentInfo() {
        // Генерируем новое имя для следующей игры
        let names = ["Морфей", "Зефир", "Игнис", "Астра", "Нексус", "Оракул", "Феникс", "Темпус", "Люмен", "Хронос", "Вортигон", "Арканум"]
        opponentName = names.randomElement() ?? "Соперник"
        
        // Генерируем новые характеристики для следующей игры
        if let playerCharacter = DataManager.shared.loadCharacter() {
            let playerTotalStats = playerCharacter.strength + playerCharacter.agility +
                                  playerCharacter.endurance + playerCharacter.wisdom +
                                  playerCharacter.intellect
            
            let deviation = Int.random(in: -2...2)
            let opponentTotalStats = max(25, playerTotalStats + deviation)
            
            var stats = [5, 5, 5, 5, 5]
            let basePoints = 25
            var remainingPoints = opponentTotalStats - basePoints
            
            while remainingPoints > 0 {
                let randomIndex = Int.random(in: 0..<5)
                stats[randomIndex] += 1
                remainingPoints -= 1
            }
            
            stats.shuffle()
            
            let statsList = """
            💪 Сила: \(stats[0])
            🏃 Ловкость: \(stats[1])
            ❤️ Выносливость: \(stats[2])
            📚 Мудрость: \(stats[3])
            🧠 Интеллект: \(stats[4])
            """
            
            gameViewModel.opponentStatsInfo = statsList
        }
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
    let isPlayer: Bool
    let statistics: GameResultView.BattleStatistics
    
    var body: some View {
        VStack(spacing: 10) {
            Text(player.name)
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 5) {
                StatItem(
                    title: "Энергия:",
                    value: "\(String(format: "%.1f", isPlayer ? statistics.player1FinalHealth : statistics.player2FinalHealth))",
                    color: (isPlayer ? statistics.player1FinalHealth : statistics.player2FinalHealth) > 0 ? .green : .red
                )
                
                StatItem(
                    title: "Нанесено урона:",
                    value: "\(String(format: "%.1f", isPlayer ? statistics.player1DamageDealt : statistics.player2DamageDealt))",
                    color: .red
                )
                
                StatItem(
                    title: "Получено урона:",
                    value: "\(String(format: "%.1f", isPlayer ? statistics.player1DamageTaken : statistics.player2DamageTaken))",
                    color: .orange
                )
                
                StatItem(
                    title: "Побед в раундах:",
                    value: "\(isPlayer ? statistics.player1RoundsWon : statistics.player2RoundsWon) из \(statistics.totalRounds)",
                    color: .blue
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

struct CharacterStatisticsView: View {
    let character: PlayerCharacter
    
    var body: some View {
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
                    Text("Получено урона")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(String(format: "%.0f", character.totalDamageTaken))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }
            
            // Добавляем информацию об общем количестве битв
            VStack(spacing: 5) {
                Text("Всего битв")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                Text("\(character.battlesWon + character.battlesLost)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
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

struct GameResultActionButtons: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            ActionButton(
                title: "Новая игра",
                action: {
                    startNewGame()
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
    
    private func startNewGame() {
        // Сбрасываем игру и генерируем нового противника
        gameViewModel.resetGame()
        
        // Генерируем нового противника с новыми характеристиками
        if let playerCharacter = DataManager.shared.loadCharacter() {
            let playerTotalStats = playerCharacter.strength + playerCharacter.agility +
                                  playerCharacter.endurance + playerCharacter.wisdom +
                                  playerCharacter.intellect
            
            let deviation = Int.random(in: -2...2)
            let opponentTotalStats = max(25, playerTotalStats + deviation)
            
            var stats = [5, 5, 5, 5, 5]
            let basePoints = 25
            var remainingPoints = opponentTotalStats - basePoints
            
            while remainingPoints > 0 {
                let randomIndex = Int.random(in: 0..<5)
                stats[randomIndex] += 1
                remainingPoints -= 1
            }
            
            stats.shuffle()
            
            // Обновляем противника
            gameViewModel.player2.strength = stats[0]
            gameViewModel.player2.agility = stats[1]
            gameViewModel.player2.endurance = stats[2]
            gameViewModel.player2.wisdom = stats[3]
            gameViewModel.player2.intellect = stats[4]
            
            // Генерируем новое имя
            let names = ["Морфей", "Зефир", "Игнис", "Астра", "Нексус", "Оракул", "Феникс", "Темпус", "Люмен", "Хронос", "Вортигон", "Арканум"]
            gameViewModel.player2.name = names.randomElement() ?? "Соперник"
            
            // Обновляем информацию о противнике
            let statsList = """
            💪 Сила: \(stats[0])
            🏃 Ловкость: \(stats[1])
            ❤️ Выносливость: \(stats[2])
            📚 Мудрость: \(stats[3])
            🧠 Интеллект: \(stats[4])
            """
            
            gameViewModel.opponentStatsInfo = statsList
        }
        
        // Переходим к выбору атак
        gameViewModel.gameState = .selection
    }
}
