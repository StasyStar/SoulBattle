import Foundation
import Combine

enum CharacterPreset {
    case warrior, mage, rogue, balanced
}

class Player: ObservableObject, Identifiable {
    let id = UUID()
    
    // Характеристики
    @Published var strength: Int
    @Published var agility: Int
    @Published var endurance: Int
    @Published var wisdom: Int
    @Published var intellect: Int
    
    // Игровое состояние
    @Published var health: Double
    @Published var isAlive: Bool = true
    
    // Выбранные атаки и защиты
    @Published var selectedAttacks: [AttackType] = []
    @Published var selectedDefenses: [DefenseType] = []
    
    // Статистика
    @Published var damageDealt: Double = 0.0
    @Published var damageTaken: Double = 0.0
    @Published var roundsWon: Int = 0
    
    // Сделаем имя изменяемым
    @Published var name: String
    
    // Система уровней
    @Published var level: Int = 1
    @Published var experience: Int = 0
    @Published var availableStatPoints: Int = 0
    
    // Ссылка на сохраненного персонажа (только для игрока)
    var savedCharacter: PlayerCharacter?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(name: String, strength: Int, agility: Int, endurance: Int, wisdom: Int, intellect: Int) {
        self.name = name
        self.strength = strength
        self.agility = agility
        self.endurance = endurance
        self.wisdom = wisdom
        self.intellect = intellect
        self.health = 80.0 + Double(endurance) * 2.0
        
        // Наблюдаем за здоровьем
        $health
            .sink { [weak self] newHealth in
                self?.isAlive = newHealth > 0
            }
            .store(in: &cancellables)
    }
    
    // Инициализатор из сохраненного персонажа
    convenience init(from character: PlayerCharacter) {
        self.init(
            name: character.name,
            strength: character.strength,
            agility: character.agility,
            endurance: character.endurance,
            wisdom: character.wisdom,
            intellect: character.intellect
        )
        self.savedCharacter = character
        self.level = character.level
        self.experience = character.experience
        self.availableStatPoints = character.availableStatPoints
    }
    
    // Удобный инициализатор для предустановок (для компьютера)
    convenience init(name: String, characterPreset: CharacterPreset) {
        switch characterPreset {
        case .warrior:
            self.init(name: name, strength: 8, agility: 5, endurance: 7, wisdom: 3, intellect: 2)
        case .mage:
            self.init(name: name, strength: 2, agility: 4, endurance: 5, wisdom: 8, intellect: 6)
        case .rogue:
            self.init(name: name, strength: 5, agility: 8, endurance: 4, wisdom: 3, intellect: 5)
        case .balanced:
            self.init(name: name, strength: 5, agility: 5, endurance: 5, wisdom: 5, intellect: 5)
        }
    }
    
    // Создание нового персонажа с распределением очков
    convenience init() {
        self.init(name: "Новый герой", strength: 5, agility: 5, endurance: 5, wisdom: 5, intellect: 5)
    }
    
    func resetSelections() {
        selectedAttacks.removeAll()
        selectedDefenses.removeAll()
    }
    
    func takeDamage(_ damage: Double) {
        let actualDamage = min(damage, health)
        health = max(health - damage, 0)
        damageTaken += actualDamage
    }
    
    func dealDamage(_ damage: Double) {
        damageDealt += damage
    }
    
    func resetForNewGame() {
        health = 80.0 + Double(endurance) * 2.0
        isAlive = true
        damageDealt = 0.0
        damageTaken = 0.0
        roundsWon = 0
        resetSelections()
    }
    
    func winRound() {
        roundsWon += 1
    }
    
    var totalStats: Int {
        strength + agility + endurance + wisdom + intellect
    }
    
    var maxHealth: Double {
        80.0 + Double(endurance) * 2.0
    }
    
    var healthPercentage: Double {
        health / maxHealth
    }
    
    func isValidStats() -> Bool {
        let totalSpentPoints = strength + agility + endurance + wisdom + intellect
        let maxAllowedPoints = 25 + (level - 1) * 2 // Базовые 25 + по 2 за каждый уровень после 1-го
        
        return strength >= 1 && agility >= 1 && endurance >= 1 &&
               wisdom >= 1 && intellect >= 1 &&
               strength <= 10 && agility <= 10 && endurance <= 10 &&
               wisdom <= 10 && intellect <= 10 &&
               totalSpentPoints <= maxAllowedPoints
    }
    
    var experienceToNextLevel: Int {
        level * 100 + 50
    }
    
    var maxAllowedStatPoints: Int {
        return 25 + (level - 1) * 2
    }
    
    // Сохранение персонажа
    func saveCharacter() {
        var character: PlayerCharacter
        if let existingCharacter = savedCharacter {
            character = existingCharacter
            // Обновляем статистику
            character.recordBattleResult(
                won: false, // Это обновляется после битвы
                damageDealt: damageDealt,
                damageTaken: damageTaken
            )
        } else {
            character = PlayerCharacter(
                name: name,
                strength: strength,
                agility: agility,
                endurance: endurance,
                wisdom: wisdom,
                intellect: intellect
            )
        }
        
        DataManager.shared.saveCharacter(character)
        savedCharacter = character
    }
}
