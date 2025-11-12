import Foundation
import Combine

enum AttackType: String, CaseIterable, Identifiable {
    case fire = "Огненная атака"
    case lightning = "Атака молнией"
    case weapon = "Атака оружием"
    case acid = "Кислотная атака"
    case psycho = "Психо-атака"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .fire: return "flame"
        case .lightning: return "bolt"
        case .weapon: return "hammer"
        case .acid: return "drop"
        case .psycho: return "brain.head.profile"
        }
    }
}

enum DefenseType: String, CaseIterable, Identifiable {
    case fire = "Защита от огня"
    case lightning = "Защита от молнии"
    case weapon = "Защита от оружия"
    case acid = "Защита от кислоты"
    case psycho = "Психо-защита"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .fire: return "flame"
        case .lightning: return "bolt"
        case .weapon: return "shield"
        case .acid: return "drop"
        case .psycho: return "brain.head.profile"
        }
    }
}

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
    
    // Изменяемое имя
    @Published var name: String
    
    // Система уровней
    @Published var level: Int = 1
    @Published var experience: Int = 0
    @Published var availableStatPoints: Int = 0
    
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
        
        $health
            .sink { [weak self] newHealth in
                self?.isAlive = newHealth > 0
            }
            .store(in: &cancellables)
    }
    
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
    }
    
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
        health = maxHealth
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
            // Обновление статистики
            character.recordBattleResult(
                won: false,
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

struct PlayerCharacter: Codable {
    let name: String
    let strength: Int
    let agility: Int
    let endurance: Int
    let wisdom: Int
    let intellect: Int
    var creationDate: Date
    var battlesWon: Int
    var battlesLost: Int
    var totalDamageDealt: Double
    var totalDamageTaken: Double
    var level: Int
    var experience: Int
    var totalBonusPoints: Int
    
    var totalStats: Int {
        strength + agility + endurance + wisdom + intellect
    }
    
    var winRate: Double {
        let totalBattles = battlesWon + battlesLost
        return totalBattles > 0 ? Double(battlesWon) / Double(totalBattles) * 100 : 0
    }
    
    var experienceToNextLevel: Int {
        level * 100 + 50
    }
    
    var maxLevel: Int {
        50
    }
    
    init(name: String, strength: Int, agility: Int, endurance: Int, wisdom: Int, intellect: Int) {
        self.name = name
        self.strength = strength
        self.agility = agility
        self.endurance = endurance
        self.wisdom = wisdom
        self.intellect = intellect
        self.creationDate = Date()
        self.battlesWon = 0
        self.battlesLost = 0
        self.totalDamageDealt = 0
        self.totalDamageTaken = 0
        self.level = 1
        self.experience = 0
        self.totalBonusPoints = 0
    }
    
    mutating func recordBattleResult(won: Bool, damageDealt: Double, damageTaken: Double) {
        if won {
            battlesWon += 1
            experience += 80 + Int(damageDealt / 10)
        } else {
            battlesLost += 1
            experience += 20 + Int(damageDealt / 20)
        }
        totalDamageDealt += damageDealt
        totalDamageTaken += damageTaken
        
        checkLevelUp()
    }
    
    mutating func checkLevelUp() {
        var levelsGained = 0
        while experience >= experienceToNextLevel && level < maxLevel {
            experience -= experienceToNextLevel
            level += 1
            levelsGained += 1
        }
        
        if levelsGained > 0 {
            totalBonusPoints += levelsGained * 2
        }
    }
    
    var totalAvailablePoints: Int {
        return 25 + 25 + totalBonusPoints // 25 базовых + 25 стартовых + бонусные
    }
}
