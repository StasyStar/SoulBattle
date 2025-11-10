import Foundation

struct PlayerCharacter: Codable {
    let name: String
    let strength: Int
    let agility: Int
    let endurance: Int
    let wisdom: Int
    let intellect: Int
    let creationDate: Date
    var battlesWon: Int
    var battlesLost: Int
    var totalDamageDealt: Double
    var totalDamageTaken: Double
    
    var totalStats: Int {
        strength + agility + endurance + wisdom + intellect
    }
    
    var winRate: Double {
        let totalBattles = battlesWon + battlesLost
        return totalBattles > 0 ? Double(battlesWon) / Double(totalBattles) * 100 : 0
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
    }
    
    mutating func recordBattleResult(won: Bool, damageDealt: Double, damageTaken: Double) {
        if won {
            battlesWon += 1
        } else {
            battlesLost += 1
        }
        totalDamageDealt += damageDealt
        totalDamageTaken += damageTaken
    }
}
