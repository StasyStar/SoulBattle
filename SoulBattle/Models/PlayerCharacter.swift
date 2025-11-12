import Foundation

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
    var totalBonusPoints: Int // ВСЕГО полученных бонусных очков за уровни (а не остаток)
    
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
        self.totalBonusPoints = 0 // Начинаем с 0 бонусных очков
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
        
        // Проверяем повышение уровня
        checkLevelUp()
    }
    
    mutating func checkLevelUp() {
        var levelsGained = 0
        while experience >= experienceToNextLevel && level < maxLevel {
            experience -= experienceToNextLevel
            level += 1
            levelsGained += 1
        }
        
        // Добавляем бонусные очки за все полученные уровни
        if levelsGained > 0 {
            totalBonusPoints += levelsGained * 2
        }
    }
    
    // Общая сумма доступных очков (для отображения)
    var totalAvailablePoints: Int {
        return 25 + 25 + totalBonusPoints // 25 базовых + 25 стартовых + бонусные
    }
}
