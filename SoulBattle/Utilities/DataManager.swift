import Foundation

class DataManager {
    static let shared = DataManager()
    private let currentUserKey = "currentUser"
    private let usersKey = "registeredUsers"
    private let testUsersKey = "testUsers"
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    var isTestingMode: Bool {
        return ProcessInfo.processInfo.arguments.contains("--UITesting") ||
               ProcessInfo.processInfo.arguments.contains("--testing")
    }
    
    private func getUsersKey() -> String {
        return isTestingMode ? testUsersKey : usersKey
    }
    
    func saveCharacter(_ character: PlayerCharacter, for username: String) -> Bool {
        var users = getAllUsers()
        guard let index = users.firstIndex(where: { $0.username == username }) else {
            return false
        }
        
        users[index].character = character
        return saveUsers(users)
    }
    
    func loadCharacter(for username: String) -> PlayerCharacter? {
        let users = getAllUsers()
        return users.first(where: { $0.username == username })?.character
    }
    
    func getCurrentUserCharacter() -> PlayerCharacter? {
        guard let currentUsername = getCurrentUser() else { return nil }
        return loadCharacter(for: currentUsername)
    }
        
    func registerUser(username: String, password: String, character: PlayerCharacter) -> Bool {
        var users = getAllUsers()
        
        if users.contains(where: { $0.username == username }) {
            return false
        }
        
        let user = UserAccount(
            username: username,
            password: password,
            character: character,
            registrationDate: Date()
        )
        
        users.append(user)
        let success = saveUsers(users)
        
        if success {
            setCurrentUser(username)
        }
        
        return success
    }
    
    func loginUser(username: String, password: String) -> Bool {
        let users = getAllUsers()
        guard users.first(where: { $0.username == username && $0.password == password }) != nil else {
            return false
        }
        
        setCurrentUser(username)
        return true
    }
    
    func logoutUser() {
        userDefaults.removeObject(forKey: currentUserKey)
    }
    
    func getCurrentUser() -> String? {
        return userDefaults.string(forKey: currentUserKey)
    }

    func isUserLoggedIn() -> Bool {
        return getCurrentUser() != nil
    }
    
    func updateCurrentUserCharacter(_ character: PlayerCharacter) -> Bool {
        guard let currentUsername = getCurrentUser() else { return false }
        return saveCharacter(character, for: currentUsername)
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
        guard let currentUsername = getCurrentUser(),
              let character = getCurrentUserCharacter() else { return nil }
        
        let users = getAllUsers()
        guard let user = users.first(where: { $0.username == currentUsername }) else {
            return nil
        }
        
        return UserStatistics(
            username: user.username,
            registrationDate: user.registrationDate,
            character: character
        )
    }
        
    func createNewCharacter(for username: String) -> PlayerCharacter {
        return PlayerCharacter(
            name: username,
            strength: 5,
            agility: 5,
            endurance: 5,
            wisdom: 5,
            intellect: 5
        )
    }
    
    func doesUserExist(_ username: String) -> Bool {
        let users = getAllUsers()
        return users.contains(where: { $0.username == username })
    }
        
    func clearTestData() {
        if isTestingMode {
            userDefaults.removeObject(forKey: testUsersKey)
            userDefaults.removeObject(forKey: currentUserKey)
        }
    }
    
    func setupTestData() {
        if isTestingMode {
            let testCharacter = PlayerCharacter(
                name: "TestHero",
                strength: 5,
                agility: 5,
                endurance: 5,
                wisdom: 5,
                intellect: 5
            )
            
            let testUser = UserAccount(
                username: "testuser",
                password: "testpass",
                character: testCharacter,
                registrationDate: Date()
            )
            
            var users = getAllUsers()
            users.append(testUser)
            _ = saveUsers(users)
        }
    }
    
    private func setCurrentUser(_ username: String) {
        userDefaults.set(username, forKey: currentUserKey)
    }
    
    private func getAllUsers() -> [UserAccount] {
        let key = getUsersKey()
        if let savedData = userDefaults.data(forKey: key) {
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
            userDefaults.set(encoded, forKey: getUsersKey())
            return true
        }
        return false
    }
}
