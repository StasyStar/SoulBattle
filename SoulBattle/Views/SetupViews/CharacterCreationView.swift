import SwiftUI

struct CharacterCreationView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var characterName: String = ""
    @State private var availablePoints: Int = GameConstants.Balance.startingExtraPoints
    @State private var strength: Int = GameConstants.Rules.minStatValue
    @State private var agility: Int = GameConstants.Rules.minStatValue
    @State private var endurance: Int = GameConstants.Rules.minStatValue
    @State private var wisdom: Int = GameConstants.Rules.minStatValue
    @State private var intellect: Int = GameConstants.Rules.minStatValue
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var isRegistration: Bool = false
    var username: String = ""
    var password: String = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple, Color.blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 15) {
                    Text(isRegistration ? "Создание персонажа" : "Редактирование персонажа")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    if !isRegistration, let currentCharacter = DataManager.shared.loadCharacter() {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Уровень \(currentCharacter.level)")
                                    .font(.headline)
                                    .foregroundColor(.yellow)
                                
                                Spacer()
                                
                                if currentCharacter.totalBonusPoints > 0 {
                                    Text("+\(currentCharacter.totalBonusPoints) бонусных очков")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.3))
                                        .cornerRadius(8)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Опыт: \(currentCharacter.experience)/\(currentCharacter.experienceToNextLevel)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(currentCharacter.experienceToNextLevel - currentCharacter.experience) до след. уровня")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                ProgressView(value: Double(currentCharacter.experience), total: Double(currentCharacter.experienceToNextLevel))
                                    .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Имя персонажа")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        
                        TextField("Введите имя", text: $characterName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 15) {
                        Text("Доступно очков: \(availablePoints)")
                            .font(.headline)
                            .foregroundColor(availablePoints >= 0 ? .green : .red)
                            .padding(.bottom, 5)
                        
                        if availablePoints < 0 {
                            Text("Слишком много очков! Уберите \(abs(availablePoints))")
                                .foregroundColor(.red)
                                .font(.caption2)
                        }
                        
                        CharacteristicRow(
                            name: "💪 Сила",
                            value: $strength,
                            availablePoints: $availablePoints,
                            color: .red
                        )
                        
                        CharacteristicRow(
                            name: "🏃 Ловкость",
                            value: $agility,
                            availablePoints: $availablePoints,
                            color: .green
                        )
                        
                        CharacteristicRow(
                            name: "❤️ Выносливость",
                            value: $endurance,
                            availablePoints: $availablePoints,
                            color: .orange
                        )
                        
                        CharacteristicRow(
                            name: "📚 Мудрость",
                            value: $wisdom,
                            availablePoints: $availablePoints,
                            color: .blue
                        )
                        
                        CharacteristicRow(
                            name: "🧠 Интеллект",
                            value: $intellect,
                            availablePoints: $availablePoints,
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        Text("Предпросмотр персонажа")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 3) {
                            Text("Здоровье: \(String(format: "%.1f", 80.0 + Double(endurance) * 2.0))")
                            Text("Сила атаки: \(calculateAttackPower())")
                            Text("Защита: \(calculateDefense())")
                        }
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    VStack(spacing: 10) {
                        Button(isRegistration ? "Создать персонажа" : "Сохранить изменения") {
                            if isRegistration {
                                createCharacterForRegistration()
                            } else {
                                updateCharacter()
                            }
                        }
                        .disabled(!isReadyToCreate)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(isReadyToCreate ? Color.green : Color.gray)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        
                        Button("Отмена") {
                            dismiss()
                        }
                        .foregroundColor(.white)
                        .font(.subheadline)
                    }
                    .padding(.top, 5)
                }
                .padding(.vertical, 10)
            }
        }
        .onAppear {
            loadCurrentCharacter()
        }
        .alert("Ошибка", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var isReadyToCreate: Bool {
        return !characterName.isEmpty && availablePoints >= 0
    }
    
    private func calculateAttackPower() -> String {
        let basePower = Double(strength + agility + wisdom + intellect) * 0.5
        return String(format: "%.1f", basePower)
    }
    
    private func calculateDefense() -> String {
        let baseDefense = Double(endurance) * GameConstants.Balance.healthPerEndurance
        return String(format: "%.1f", baseDefense)
    }
    
    private func createCharacterForRegistration() {
        let character = PlayerCharacter(
            name: characterName.isEmpty ? username : characterName,
            strength: strength,
            agility: agility,
            endurance: endurance,
            wisdom: wisdom,
            intellect: intellect
        )
        
        let success = DataManager.shared.registerUser(username: username, password: password, character: character)
        
        if success {
            DataManager.shared.saveCharacter(character)
            viewModel.player1 = Player(from: character)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                viewModel.gameState = .mainMenu
                dismiss()
            }
        } else {
            errorMessage = "Не удалось создать аккаунт. Возможно, пользователь с таким именем уже существует."
            showErrorAlert = true
        }
    }
    
    private func updateCharacter() {
        guard let currentCharacter = DataManager.shared.loadCharacter() else { return }
        
        var updatedCharacter = PlayerCharacter(
            name: characterName,
            strength: strength,
            agility: agility,
            endurance: endurance,
            wisdom: wisdom,
            intellect: intellect
        )
        
        updatedCharacter.level = currentCharacter.level
        updatedCharacter.experience = currentCharacter.experience
        updatedCharacter.battlesWon = currentCharacter.battlesWon
        updatedCharacter.battlesLost = currentCharacter.battlesLost
        updatedCharacter.totalDamageDealt = currentCharacter.totalDamageDealt
        updatedCharacter.totalDamageTaken = currentCharacter.totalDamageTaken
        updatedCharacter.creationDate = currentCharacter.creationDate
        updatedCharacter.totalBonusPoints = currentCharacter.totalBonusPoints
        
        DataManager.shared.saveCharacter(updatedCharacter)
        
        if DataManager.shared.getCurrentUser() != nil {
            _ = DataManager.shared.updateCurrentUserCharacter(updatedCharacter)
        }
        
        viewModel.player1 = Player(from: updatedCharacter)
        
        print("=== СОХРАНЕНИЕ ===")
        print("Всего характеристик: \(strength + agility + endurance + wisdom + intellect)")
        print("Бонусных очков получено: \(currentCharacter.totalBonusPoints)")
        print("Сохранено бонусных очков: \(updatedCharacter.totalBonusPoints)")
        
        dismiss()
    }
    
    private func loadCurrentCharacter() {
        if let currentCharacter = DataManager.shared.loadCharacter() {
            characterName = currentCharacter.name
            strength = currentCharacter.strength
            agility = currentCharacter.agility
            endurance = currentCharacter.endurance
            wisdom = currentCharacter.wisdom
            intellect = currentCharacter.intellect
            
            let totalCurrentStats = strength + agility + endurance + wisdom + intellect
            let totalAvailablePoints = GameConstants.Balance.baseStatPoints +
                                     GameConstants.Balance.startingExtraPoints +
                                     currentCharacter.totalBonusPoints
            
            availablePoints = totalAvailablePoints - totalCurrentStats
            
            print("=== ЗАГРУЗКА ===")
            print("Уровень: \(currentCharacter.level)")
            print("Всего бонусных очков получено: \(currentCharacter.totalBonusPoints)")
            print("Всего доступно очков: \(totalAvailablePoints)")
            print("Уже потрачено очков: \(totalCurrentStats)")
            print("Осталось доступных очков: \(availablePoints)")
            
        } else if isRegistration {
            characterName = username.isEmpty ? GameConstants.Defaults.playerName : username
            strength = GameConstants.Rules.minStatValue
            agility = GameConstants.Rules.minStatValue
            endurance = GameConstants.Rules.minStatValue
            wisdom = GameConstants.Rules.minStatValue
            intellect = GameConstants.Rules.minStatValue
            availablePoints = GameConstants.Balance.startingExtraPoints
        }
    }
}

struct CharacteristicRow: View {
    let name: String
    @Binding var value: Int
    @Binding var availablePoints: Int
    let color: Color
    let minValue: Int = 5
    
    var body: some View {
        HStack {
            Text(name)
                .foregroundColor(.white)
                .font(.caption)
                .frame(width: 110, alignment: .leading)
            
            Spacer()
            
            Text("\(value)")
                .foregroundColor(.white)
                .fontWeight(.bold)
                .font(.caption)
                .frame(width: 20)
            
            HStack(spacing: 8) {
                Button("-") {
                    if value > minValue {
                        value -= 1
                        availablePoints += 1
                    }
                }
                .buttonStyle(CharacteristicButtonStyle(color: color))
                .disabled(value <= minValue)
                
                Button("+") {
                    if availablePoints > 0 {
                        value += 1
                        availablePoints -= 1
                    }
                }
                .buttonStyle(CharacteristicButtonStyle(color: color))
                .disabled(availablePoints <= 0)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)
    }
}

struct CharacteristicButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .foregroundColor(.white)
            .frame(width: 25, height: 25)
            .background(color)
            .cornerRadius(5)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}
