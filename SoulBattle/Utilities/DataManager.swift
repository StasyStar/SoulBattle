import Foundation

class DataManager {
    static let shared = DataManager()
    
    private let userDefaults = UserDefaults.standard
    private let savedCharacterKey = "savedCharacter"
    
    private init() {}
    
    // Сохраняем персонажа
    func saveCharacter(_ character: PlayerCharacter) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(character) {
            userDefaults.set(encoded, forKey: savedCharacterKey)
        }
    }
    
    // Загружаем персонажа
    func loadCharacter() -> PlayerCharacter? {
        if let savedData = userDefaults.data(forKey: savedCharacterKey) {
            let decoder = JSONDecoder()
            if let loadedCharacter = try? decoder.decode(PlayerCharacter.self, from: savedData) {
                return loadedCharacter
            }
        }
        return nil
    }
    
    // Удаляем сохраненного персонажа
    func deleteCharacter() {
        userDefaults.removeObject(forKey: savedCharacterKey)
    }
    
    // Проверяем есть ли сохраненный персонаж
    func hasSavedCharacter() -> Bool {
        return loadCharacter() != nil
    }
}
