import Foundation

struct UserAccount: Codable {
    let username: String
    let password: String
    var character: PlayerCharacter
    let registrationDate: Date
}

struct UserStatistics {
    let username: String
    let registrationDate: Date
    let character: PlayerCharacter
    
    var playTime: String {
        let interval = Date().timeIntervalSince(registrationDate)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return "\(hours)ч \(minutes)м"
    }
    
    var battlesPlayed: Int {
        return character.battlesWon + character.battlesLost
    }
}
