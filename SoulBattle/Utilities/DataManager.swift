import Foundation

class DataManager {
    static let shared = DataManager()
    
    private let userDefaults = UserDefaults.standard
    private let savedCharacterKey = "savedCharacter"
    private let currentUserKey = "currentUser"
    private let usersKey = "registeredUsers"
    
    private init() {}
    
    // MARK: - Character Management
    
    func saveCharacter(_ character: PlayerCharacter) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(character) {
            userDefaults.set(encoded, forKey: savedCharacterKey)
        }
    }
    
    func loadCharacter() -> PlayerCharacter? {
        if let savedData = userDefaults.data(forKey: savedCharacterKey) {
            let decoder = JSONDecoder()
            if let loadedCharacter = try? decoder.decode(PlayerCharacter.self, from: savedData) {
                return loadedCharacter
            }
        }
        return nil
    }
    
    func deleteCharacter() {
        userDefaults.removeObject(forKey: savedCharacterKey)
    }
    
    func hasSavedCharacter() -> Bool {
        return loadCharacter() != nil
    }
    
    // MARK: - User Management
    
    func registerUser(username: String, password: String, character: PlayerCharacter) -> Bool {
        var users = getAllUsers()
        
        // Проверяем, не занят ли username
        if users.contains(where: { $0.username == username }) {
            return false
        }
        
        let user = UserAccount(
            username: username,
            password: password, // В реальном приложении нужно хэшировать
            character: character,
            registrationDate: Date()
        )
        
        users.append(user)
        return saveUsers(users)
    }
    
    func loginUser(username: String, password: String) -> Bool {
        let users = getAllUsers()
        guard let user = users.first(where: { $0.username == username && $0.password == password }) else {
            return false
        }
        
        // Сохраняем текущего пользователя
        setCurrentUser(username)
        // Загружаем персонажа
        saveCharacter(user.character)
        return true
    }
    
    func logoutUser() {
        userDefaults.removeObject(forKey: currentUserKey)
        deleteCharacter()
    }
    
    func getCurrentUser() -> String? {
        return userDefaults.string(forKey: currentUserKey)
    }

    func isUserLoggedIn() -> Bool {
        return getCurrentUser() != nil && hasSavedCharacter()
    }
    
    func updateCurrentUserCharacter(_ character: PlayerCharacter) -> Bool {
        guard let currentUsername = getCurrentUser() else { return false }
        
        var users = getAllUsers()
        guard let index = users.firstIndex(where: { $0.username == currentUsername }) else {
            return false
        }
        
        users[index].character = character
        return saveUsers(users)
    }
    
    func deleteUserAccount() -> Bool {
        guard let currentUsername = getCurrentUser() else { return false }
        
        var users = getAllUsers()
        users.removeAll { $0.username == currentUsername }
        
        let success = saveUsers(users)
        if success {
            logoutUser()
        }
        return success
    }
    
    func getUserStatistics() -> UserStatistics? {
        guard let character = loadCharacter() else { return nil }
        
        let users = getAllUsers()
        guard let user = users.first(where: { $0.username == getCurrentUser() }) else {
            return nil
        }
        
        return UserStatistics(
            username: user.username,
            registrationDate: user.registrationDate,
            character: character
        )
    }
    
    // MARK: - Private Methods
    
    private func setCurrentUser(_ username: String) {
        userDefaults.set(username, forKey: currentUserKey)
    }
    
    private func getAllUsers() -> [UserAccount] {
        if let savedData = userDefaults.data(forKey: usersKey) {
            let decoder = JSONDecoder()
            if let loadedUsers = try? decoder.decode([UserAccount].self, from: savedData) {
                return loadedUsers
            }
        }
        return []
    }
    
    private func saveUsers(_ users: [UserAccount]) -> Bool {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(users) {
            userDefaults.set(encoded, forKey: usersKey)
            return true
        }
        return false
    }
}

// MARK: - User Account Model

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
