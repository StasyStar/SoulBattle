import SwiftUI
import Combine

// Добавляем enum'ы и структуры ПЕРЕД классом GameViewModel
enum GameState {
    case authentication, characterCreation, mainMenu, setup, selection, battle, result
}

enum GameMode {
    case pvp, pve
}

struct RoundDetails {
    let roundNumber: Int
    let player1Attacks: [AttackType]
    let player1Defenses: [DefenseType]
    let player2Attacks: [AttackType]
    let player2Defenses: [DefenseType]
    let player1DamageDealt: Double
    let player2DamageDealt: Double
    let player1HealthAfter: Double
    let player2HealthAfter: Double
}

class GameViewModel: ObservableObject {
    @Published var gameState: GameState = .characterCreation
    @Published var currentRound: Int = 1
    @Published var gameLog: [String] = []
    @Published var gameMode: GameMode = .pvp
    
    @Published var player1: Player
    @Published var player2: Player
    
    @Published var roundDetails: RoundDetails?
    
    private let battleSystem = BattleSystem()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Проверяем есть ли сохраненный персонаж
        if let savedCharacter = DataManager.shared.loadCharacter() {
            self.player1 = Player(from: savedCharacter)
            self.gameState = .mainMenu
        } else {
            self.player1 = Player(name: "Игрок", characterPreset: .warrior)
            self.gameState = .authentication
        }
        
        self.player2 = Player(name: "Компьютер", characterPreset: .mage)
        
        setupPlayerObservers()
        addToLog("Добро пожаловать в Soul Battle!")
    }
    
    // МЕТОД ДЛЯ ПРИНУДИТЕЛЬНОГО ОБНОВЛЕНИЯ
    func forceUpdate() {
        self.objectWillChange.send()
    }
    
    // MARK: - Game Mode Management
    func startPVPGame() {
        gameMode = .pvp
        player1.name = DataManager.shared.loadCharacter()?.name ?? "Игрок 1"
        player2.name = "Игрок 2"
        resetGame()
        gameState = .setup
        addToLog("Режим: Игрок vs Игрок")
    }
    
    func startPVEGame() {
        gameMode = .pve
        player1.name = DataManager.shared.loadCharacter()?.name ?? "Игрок"
        player2.name = "Компьютер"
        resetGame()
        gameState = .setup
        addToLog("Режим: Игрок vs Компьютер")
        
        // Сразу делаем случайные выборы за компьютер
        makeRandomAISelections()
    }
    
    // MARK: - Game Flow
    func startGame() {
        gameState = .selection
        currentRound = 1
        addToLog("Игра началась! \(player1.name) против \(player2.name)")
        
        // В PVE режиме сразу делаем случайные выборы за компьютер
        if gameMode == .pve {
            makeRandomAISelections()
        }
    }
    
    func executeRound() {
        guard areSelectionsValid() else {
            addToLog("\(player1.name) должен выбрать по 2 атаки и 2 защиты!")
            return
        }
        
        gameState = .battle
        addToLog("=== Раунд \(currentRound) ===")
        
        // Сохраняем выборы для отображения в результатах
        let player1Attacks = player1.selectedAttacks
        let player1Defenses = player1.selectedDefenses
        let player2Attacks = player2.selectedAttacks
        let player2Defenses = player2.selectedDefenses
        
        // Расчет урона
        let damageToPlayer2 = battleSystem.calculateDamage(attacker: player1, defender: player2)
        let damageToPlayer1 = battleSystem.calculateDamage(attacker: player2, defender: player1)
        
        // Применение урона
        player2.takeDamage(damageToPlayer2)
        player1.takeDamage(damageToPlayer1)
        
        player1.dealDamage(damageToPlayer1)
        player2.dealDamage(damageToPlayer2)
        
        // Создаем детали раунда для отображения
        roundDetails = RoundDetails(
            roundNumber: currentRound,
            player1Attacks: player1Attacks,
            player1Defenses: player1Defenses,
            player2Attacks: player2Attacks,
            player2Defenses: player2Defenses,
            player1DamageDealt: damageToPlayer2,
            player2DamageDealt: damageToPlayer1,
            player1HealthAfter: player1.health,
            player2HealthAfter: player2.health
        )
        
        addToLog("\(player1.name): \(String(format: "%.1f", player1.health)) HP")
        addToLog("\(player2.name): \(String(format: "%.1f", player2.health)) HP")
        
        // Проверка окончания игры
        if player1.health <= 0 || player2.health <= 0 {
            endGame()
        } else {
            currentRound += 1
            resetSelections()
            gameState = .selection
            
            // В PVE режиме делаем новые случайные выборы для компьютера
            if gameMode == .pve {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.makeRandomAISelections()
                }
            }
        }
    }
    
    // Простые случайные выборы для компьютера
    private func makeRandomAISelections() {
        // Случайные атаки
        let randomAttacks = AttackType.allCases.shuffled().prefix(2)
        player2.selectedAttacks = Array(randomAttacks)
        
        // Случайные защиты
        let randomDefenses = DefenseType.allCases.shuffled().prefix(2)
        player2.selectedDefenses = Array(randomDefenses)
        
        // Принудительно обновляем после выбора
        self.objectWillChange.send()
    }
    
    // MARK: - Reset and Utilities
    
    func areSelectionsValid() -> Bool {
        let player1Ready = player1.selectedAttacks.count == 2 &&
                          player1.selectedDefenses.count == 2
        
        if gameMode == .pvp {
            let player2Ready = player2.selectedAttacks.count == 2 &&
                              player2.selectedDefenses.count == 2
            return player1Ready && player2Ready
        } else {
            return player1Ready
        }
    }
    
    func resetGame() {
        player1.resetForNewGame()
        player2.resetForNewGame()
        currentRound = 1
        gameLog.removeAll()
        resetSelections()
        roundDetails = nil
        addToLog("Новая игра началась!")
    }
    
    func backToMainMenu() {
        gameState = .mainMenu
        resetGame()
    }
    
    private func resetSelections() {
        player1.resetSelections()
        player2.resetSelections()
        
        // В PVE режиме сразу делаем случайные выборы для компьютера
        if gameMode == .pve {
            makeRandomAISelections()
        }
    }
    
    private func endGame() {
        gameState = .result
        if player1.health <= 0 && player2.health <= 0 {
            addToLog("НИЧЬЯ! Оба игрока пали в бою!")
        } else if player1.health <= 0 {
            addToLog("\(player2.name) ПОБЕДИЛ!")
            player2.winRound()
            updateCharacterStatistics(won: false)
        } else {
            addToLog("\(player1.name) ПОБЕДИЛ!")
            player1.winRound()
            updateCharacterStatistics(won: true)
        }
    }
    
    private func updateCharacterStatistics(won: Bool) {
        if var character = DataManager.shared.loadCharacter() {
            character.recordBattleResult(
                won: won,
                damageDealt: player1.damageDealt,
                damageTaken: player1.damageTaken
            )
            DataManager.shared.saveCharacter(character)
        }
    }
    
    private func setupPlayerObservers() {
        player1.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        player2.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    private func addToLog(_ message: String) {
        gameLog.append(message)
    }
}
