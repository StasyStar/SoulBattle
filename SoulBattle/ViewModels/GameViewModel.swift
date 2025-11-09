import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var gameState: GameState = .setup
    @Published var currentRound: Int = 1
    @Published var gameLog: [String] = []
    
    @Published var player1: Player
    @Published var player2: Player
    
    private let battleSystem = BattleSystem()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Создаем игроков по умолчанию
        self.player1 = Player(name: "Воин", characterPreset: .warrior)
        self.player2 = Player(name: "Маг", characterPreset: .mage)
        
        setupPlayerObservers()
        addToLog("Добро пожаловать в Soul Battle!")
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
    
    func startGame() {
        gameState = .selection
        currentRound = 1
        addToLog("Игра началась! \(player1.name) против \(player2.name)")
    }
    
    func executeRound() {
        // Автоматически добавляем выборы для тестирования
        if player1.selectedAttacks.isEmpty {
            player1.selectedAttacks = [.fire, .weapon]
            player1.selectedDefenses = [.fire, .weapon]
        }
        if player2.selectedAttacks.isEmpty {
            player2.selectedAttacks = [.lightning, .psycho]
            player2.selectedDefenses = [.lightning, .psycho]
        }
        
        guard areSelectionsValid() else {
            addToLog("Оба игрока должны выбрать по 2 атаки и 2 защиты!")
            return
        }
        
        gameState = .battle
        addToLog("=== Раунд \(currentRound) ===")
        
        // Расчет урона
        let damageToPlayer2 = battleSystem.calculateDamage(attacker: player1, defender: player2)
        let damageToPlayer1 = battleSystem.calculateDamage(attacker: player2, defender: player1)
        
        // Применение урона
        player2.takeDamage(damageToPlayer2)
        player1.takeDamage(damageToPlayer1)
        
        player1.dealDamage(damageToPlayer1)
        player2.dealDamage(damageToPlayer2)
        
        addToLog("\(player1.name): \(String(format: "%.1f", player1.health)) HP")
        addToLog("\(player2.name): \(String(format: "%.1f", player2.health)) HP")
        
        // Проверка окончания игры
        if player1.health <= 0 || player2.health <= 0 {
            endGame()
        } else {
            currentRound += 1
            resetSelections()
            gameState = .selection
        }
    }
    
    func resetGame() {
        player1.resetForNewGame()
        player2.resetForNewGame()
        currentRound = 1
        gameLog.removeAll()
        resetSelections()
        gameState = .setup
        addToLog("Новая игра началась!")
    }
    
    private func areSelectionsValid() -> Bool {
        return player1.selectedAttacks.count == 2 &&
               player1.selectedDefenses.count == 2 &&
               player2.selectedAttacks.count == 2 &&
               player2.selectedDefenses.count == 2
    }
    
    private func resetSelections() {
        player1.resetSelections()
        player2.resetSelections()
    }
    
    private func endGame() {
        gameState = .result
        if player1.health <= 0 && player2.health <= 0 {
            addToLog("НИЧЬЯ! Оба игрока пали в бою!")
        } else if player1.health <= 0 {
            addToLog("\(player2.name) ПОБЕДИЛ!")
            player2.winRound()
        } else {
            addToLog("\(player1.name) ПОБЕДИЛ!")
            player1.winRound()
        }
    }
    
    private func addToLog(_ message: String) {
        gameLog.append(message)
        print("SoulBattle: \(message)")
    }
}

enum GameState {
    case setup, selection, battle, result
}
