import Foundation

struct PlayerCharacter: Codable {
    let name: String
    let strength: Int
    let agility: Int
    let endurance: Int
    let wisdom: Int
    let intellect: Int
    var creationDate: Date // Изменяем на var
    var battlesWon: Int
    var battlesLost: Int
    var totalDamageDealt: Double
    var totalDamageTaken: Double
    var level: Int
    var experience: Int
    var availableStatPoints: Int
    
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
        self.availableStatPoints = 0
    }
    
    mutating func recordBattleResult(won: Bool, damageDealt: Double, damageTaken: Double) {
        if won {
            battlesWon += 1
            // Больше опыта за победу
            experience += 80 + Int(damageDealt / 10)
        } else {
            battlesLost += 1
            // Меньше опыта за поражение
            experience += 20 + Int(damageDealt / 20)
        }
        totalDamageDealt += damageDealt
        totalDamageTaken += damageTaken
        
        // Проверяем повышение уровня
        checkLevelUp()
    }
    
    mutating func checkLevelUp() {
        while experience >= experienceToNextLevel && level < maxLevel {
            experience -= experienceToNextLevel
            level += 1
            availableStatPoints += 2 // 2 очка характеристик за уровень
        }
    }
    
    mutating func addStatPoint(to stat: inout Int) {
        if availableStatPoints > 0 && stat < 10 {
            stat += 1
            availableStatPoints -= 1
        }
    }
}
