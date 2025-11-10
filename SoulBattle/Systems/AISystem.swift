import Foundation

class AISystem {
    
    // Стратегии ИИ
    enum AIStrategy {
        case aggressive    // Фокусируется на атаке
        case defensive     // Фокусируется на защите
        case balanced      // Сбалансированная стратегия
        case adaptive      // Адаптируется под противника
        case random        // Случайный выбор
    }
    
    func makeSelections(for aiPlayer: Player, against opponent: Player) -> (attacks: [AttackType], defenses: [DefenseType]) {
        let strategy = determineStrategy(for: aiPlayer, against: opponent)
        
        let attacks = selectAttacks(strategy: strategy, for: aiPlayer, against: opponent)
        let defenses = selectDefenses(strategy: strategy, for: aiPlayer, against: opponent)
        
        return (attacks, defenses)
    }
    
    private func determineStrategy(for aiPlayer: Player, against opponent: Player) -> AIStrategy {
        // Анализируем состояние игры для выбора стратегии
        
        // Если у ИИ мало здоровья - защищаемся
        if aiPlayer.health < 30 {
            return .defensive
        }
        
        // Если у противника мало здоровья - атакуем
        if opponent.health < 30 {
            return .aggressive
        }
        
        // Анализируем характеристики для выбора стратегии
        let aiStats = aiPlayer.totalStats
        let opponentStats = opponent.totalStats
        
        if aiStats > opponentStats + 5 {
            return .aggressive
        } else if opponentStats > aiStats + 5 {
            return .defensive
        }
        
        // Случайный выбор между сбалансированной и адаптивной стратегией
        return [AIStrategy.balanced, .adaptive].randomElement()!
    }
    
    private func selectAttacks(strategy: AIStrategy, for aiPlayer: Player, against opponent: Player) -> [AttackType] {
        var availableAttacks = AttackType.allCases
        
        // Взвешиваем атаки в зависимости от характеристик игрока
        let weightedAttacks = availableAttacks.map { attack -> (AttackType, Double) in
            let weight = calculateAttackWeight(attack: attack, for: aiPlayer, against: opponent, strategy: strategy)
            return (attack, weight)
        }
        
        // Сортируем по весу и берем топ-2
        let selectedAttacks = weightedAttacks
            .sorted { $0.1 > $1.1 }
            .prefix(2)
            .map { $0.0 }
        
        return Array(selectedAttacks)
    }
    
    private func selectDefenses(strategy: AIStrategy, for aiPlayer: Player, against opponent: Player) -> [DefenseType] {
        var availableDefenses = DefenseType.allCases
        
        // Предсказываем какие атаки может использовать противник
        let predictedOpponentAttacks = predictOpponentAttacks(opponent: opponent)
        
        let weightedDefenses = availableDefenses.map { defense -> (DefenseType, Double) in
            let weight = calculateDefenseWeight(defense: defense,
                                              predictedAttacks: predictedOpponentAttacks,
                                              strategy: strategy,
                                              for: aiPlayer)
            return (defense, weight)
        }
        
        // Сортируем по весу и берем топ-2
        let selectedDefenses = weightedDefenses
            .sorted { $0.1 > $1.1 }
            .prefix(2)
            .map { $0.0 }
        
        return Array(selectedDefenses)
    }
    
    private func calculateAttackWeight(attack: AttackType, for aiPlayer: Player, against opponent: Player, strategy: AIStrategy) -> Double {
        var weight: Double = 1.0
        
        // Базовая эффективность против характеристик противника
        switch attack {
        case .fire, .acid, .psycho:
            // Эффективно против магов
            weight += Double(opponent.wisdom) * 0.1
            weight += Double(opponent.intellect) * 0.1
        case .weapon:
            // Эффективно против воинов
            weight += Double(opponent.strength) * 0.1
        case .lightning:
            // Эффективно против ловких
            weight += Double(opponent.agility) * 0.1
        }
        
        // Учет характеристик ИИ
        switch attack {
        case .fire, .acid, .psycho:
            weight += Double(aiPlayer.wisdom) * 0.2
            weight += Double(aiPlayer.intellect) * 0.2
        case .weapon:
            weight += Double(aiPlayer.strength) * 0.3
        case .lightning:
            weight += Double(aiPlayer.agility) * 0.3
        }
        
        // Влияние стратегии
        switch strategy {
        case .aggressive:
            weight *= 1.3
        case .defensive:
            weight *= 0.7
        case .balanced, .adaptive:
            break
        case .random:
            weight = Double.random(in: 0.5...2.0)
        }
        
        // Случайный фактор для разнообразия
        weight *= Double.random(in: 0.8...1.2)
        
        return weight
    }
    
    private func calculateDefenseWeight(defense: DefenseType, predictedAttacks: [AttackType], strategy: AIStrategy, for aiPlayer: Player) -> Double {
        var weight: Double = 1.0
        
        // Эффективность против предсказанных атак
        for attack in predictedAttacks {
            switch (defense, attack) {
            case (.fire, .fire), (.lightning, .lightning), (.weapon, .weapon), (.acid, .acid), (.psycho, .psycho):
                weight += 2.0 // Прямой контрпик
            case (.fire, .acid), (.acid, .fire):
                weight += 0.5 // Частичный контрпик
            default:
                break
            }
        }
        
        // Учет выносливости для защит
        weight += Double(aiPlayer.endurance) * 0.1
        
        // Влияние стратегии
        switch strategy {
        case .defensive:
            weight *= 1.5
        case .aggressive:
            weight *= 0.7
        case .balanced, .adaptive:
            break
        case .random:
            weight = Double.random(in: 0.5...2.0)
        }
        
        // Случайный фактор
        weight *= Double.random(in: 0.8...1.2)
        
        return weight
    }
    
    private func predictOpponentAttacks(opponent: Player) -> [AttackType] {
        // Простая эвристика для предсказания атак противника
        var predictedAttacks: [AttackType] = []
        
        // Основано на характеристиках противника
        if opponent.strength > 7 {
            predictedAttacks.append(.weapon)
        }
        if opponent.wisdom > 7 || opponent.intellect > 7 {
            predictedAttacks.append(contentsOf: [.fire, .psycho])
        }
        if opponent.agility > 7 {
            predictedAttacks.append(.lightning)
        }
        
        // Если не можем предсказать, используем случайные
        if predictedAttacks.isEmpty {
            predictedAttacks = Array(AttackType.allCases.shuffled().prefix(2))
        }
        
        return predictedAttacks
    }
}
