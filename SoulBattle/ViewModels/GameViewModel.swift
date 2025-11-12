import SwiftUI
import Combine

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
    @Published var opponentStatsInfo: String = ""
    
    @Published var player1: Player
    @Published var player2: Player
    
    @Published var roundDetails: RoundDetails?
    
    private let battleSystem = BattleSystem()
    private let aiSystem = AISystem()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
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
    
    func forceUpdate() {
        self.objectWillChange.send()
    }
    
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
        
        // Выбор за компьютер
        makeAISelections()
    }
    
    // MARK: - Game Flow
    func startGame() {
        gameState = .selection
        currentRound = 1
        resetPlayerHealth() // Сбрасываем здоровье перед началом игры
        addToLog("Игра началась! \(player1.name) против \(player2.name)")
        
        // В PVE выбор за компьютер
        if gameMode == .pve {
            makeAISelections()
        }
    }
    
    func executeRound() {
        guard areSelectionsValid() else {
            addToLog("\(player1.name) должен выбрать по 2 атаки и 2 защиты!")
            return
        }
        
        gameState = .battle
        addToLog("=== Раунд \(currentRound) ===")
        
        let player1Selections = formatSelections(attacks: player1.selectedAttacks, defenses: player1.selectedDefenses)
        let player2Selections = formatSelections(attacks: player2.selectedAttacks, defenses: player2.selectedDefenses)
        
        addToLog("\(player1.name): \(player1Selections)")
        addToLog("\(player2.name): \(player2Selections)")
        
        let player1Attacks = player1.selectedAttacks
        let player1Defenses = player1.selectedDefenses
        let player2Attacks = player2.selectedAttacks
        let player2Defenses = player2.selectedDefenses
        
        let damageToPlayer2 = battleSystem.calculateDamage(attacker: player1, defender: player2)
        let damageToPlayer1 = battleSystem.calculateDamage(attacker: player2, defender: player1)
        
        player2.takeDamage(damageToPlayer2)
        player1.takeDamage(damageToPlayer1)
        
        player1.dealDamage(damageToPlayer2)
        player2.dealDamage(damageToPlayer1)
        
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
        
        // Добавление информацию об уроне в лог
        addToLog("\(player1.name) нанес \(String(format: "%.1f", damageToPlayer2)) урона")
        addToLog("\(player2.name) нанес \(String(format: "%.1f", damageToPlayer1)) урона")
        addToLog("\(player1.name): \(String(format: "%.0f", player1.health)) HP")
        addToLog("\(player2.name): \(String(format: "%.0f", player2.health)) HP")
        
        // Определение победителя раунда
        determineRoundWinner()
        
        if player1.health <= 0 || player2.health <= 0 {
            endGame()
        } else {
            currentRound += 1
            resetSelections()
            gameState = .selection
            
            if gameMode == .pve {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.makeAISelections()
                }
            }
        }
    }
    
    private func makeAISelections() {
        let selections = aiSystem.makeSelections(for: player2, against: player1)
        player2.selectedAttacks = selections.attacks
        player2.selectedDefenses = selections.defenses
        
        self.objectWillChange.send()
    }
    
    private func determineRoundWinner() {
        if let details = roundDetails {
            if details.player1DamageDealt > details.player2DamageDealt {
                player1.roundsWon += 1
                addToLog("🎯 \(player1.name) выиграл раунд!")
            } else if details.player2DamageDealt > details.player1DamageDealt {
                player2.roundsWon += 1
                addToLog("🎯 \(player2.name) выиграл раунд!")
            } else {
                addToLog("⚖️ Раунд окончился вничью!")
            }
        }
    }
    
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
        
        if gameMode == .pve {
            makeAISelections()
        }
    }
    
    private func endGame() {
        gameState = .result
        
        // Определение победителя и обновление статистики
        if player1.health <= 0 && player2.health <= 0 {
            addToLog("НИЧЬЯ! Оба игрока пали в бою!")
            // За ничью тоже даем немного опыта
            updateCharacterAfterBattle(won: false, isDraw: true)
        } else if player1.health <= 0 {
            addToLog("\(player2.name) ПОБЕДИЛ!")
            player2.winRound()
            updateCharacterAfterBattle(won: false, isDraw: false)
        } else {
            addToLog("\(player1.name) ПОБЕДИЛ!")
            player1.winRound()
            updateCharacterAfterBattle(won: true, isDraw: false)
        }
    }

    private func updateCharacterAfterBattle(won: Bool, isDraw: Bool) {
        if var character = DataManager.shared.loadCharacter() {
            let oldLevel = character.level
            
            character.recordBattleResult(
                won: won,
                damageDealt: player1.damageDealt,
                damageTaken: player1.damageTaken
            )
            
            DataManager.shared.saveCharacter(character)
            
            // Проверка, был ли получен новый уровень
            if character.level > oldLevel {
                let levelsGained = character.level - oldLevel
                addToLog("🎉 Получен \(character.level) уровень! +\(levelsGained * 2) очков характеристик")
            }
            
            player1 = Player(from: character)
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
    
    func resetPlayerHealth() {
        player1.health = player1.maxHealth
        player2.health = player2.maxHealth
    }
    
    // Получение иконки атаки
    private func getAttackIcon(_ attack: AttackType) -> String {
        switch attack {
        case .fire: return "🔥"
        case .lightning: return "⚡️"
        case .weapon: return "🗡️"
        case .acid: return "💧"
        case .psycho: return "🧠"
        }
    }

    // Получение иконки защиты
    private func getDefenseIcon(_ defense: DefenseType) -> String {
        switch defense {
        case .fire: return "🔥"
        case .lightning: return "⚡️"
        case .weapon: return "🗡️"
        case .acid: return "💧"
        case .psycho: return "🧠"
        }
    }

    private func formatSelections(attacks: [AttackType], defenses: [DefenseType]) -> String {
        let attackIcons = attacks.map { getAttackIcon($0) }.joined(separator: " + ")
        let defenseIcons = defenses.map { getDefenseIcon($0) }.joined(separator: " + ")
        return "Атака: \(attackIcons), Защита: \(defenseIcons)"
    }
}
