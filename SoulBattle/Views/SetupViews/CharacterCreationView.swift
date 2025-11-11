import SwiftUI

struct CharacterCreationView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var characterName: String = ""
    @State private var availablePoints: Int = 25
    @State private var strength: Int = 5
    @State private var agility: Int = 5
    @State private var endurance: Int = 5
    @State private var wisdom: Int = 5
    @State private var intellect: Int = 5
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var isRegistration: Bool = false
    var username: String = ""
    var password: String = ""
    
    var body: some View {
        ZStack {
            // Фон
            LinearGradient(
                gradient: Gradient(colors: [Color.purple, Color.blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 15) {
                    // Заголовок
                    Text(isRegistration ? "Создание персонажа" : "Редактирование персонажа")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Информация об уровне (только для редактирования)
                    if !isRegistration, let currentCharacter = DataManager.shared.loadCharacter() {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Уровень \(currentCharacter.level)")
                                    .font(.headline)
                                    .foregroundColor(.yellow)
                                
                                Spacer()
                                
                                if currentCharacter.availableStatPoints > 0 {
                                    Text("+\(currentCharacter.availableStatPoints) очков")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.3))
                                        .cornerRadius(8)
                                }
                            }
                            
                            // Прогресс опыта
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
                    
                    // Имя персонажа
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Имя персонажа")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        
                        TextField("Введите имя", text: $characterName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    
                    // Очки характеристик
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
                            color: .red,
                            minValue: 5
                        )
                        
                        CharacteristicRow(
                            name: "🏃 Ловкость",
                            value: $agility,
                            availablePoints: $availablePoints,
                            color: .green,
                            minValue: 5
                        )
                        
                        CharacteristicRow(
                            name: "❤️ Выносливость",
                            value: $endurance,
                            availablePoints: $availablePoints,
                            color: .orange,
                            minValue: 5
                        )
                        
                        CharacteristicRow(
                            name: "📚 Мудрость",
                            value: $wisdom,
                            availablePoints: $availablePoints,
                            color: .blue,
                            minValue: 5
                        )
                        
                        CharacteristicRow(
                            name: "🧠 Интеллект",
                            value: $intellect,
                            availablePoints: $availablePoints,
                            color: .purple,
                            minValue: 5
                        )
                    }
                    .padding(.horizontal)
                    
                    // Предпросмотр характеристик
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
                    
                    // Кнопки
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
        return !characterName.isEmpty && availablePoints == 0
    }
    
    private func calculateAttackPower() -> String {
        let basePower = Double(strength + agility + wisdom + intellect) * 0.5
        return String(format: "%.1f", basePower)
    }
    
    private func calculateDefense() -> String {
        let baseDefense = Double(endurance) * 2.0
        return String(format: "%.1f", baseDefense)
    }
    
    private func createCharacterForRegistration() {
        print("=== ПОПЫТКА СОЗДАНИЯ ПЕРСОНАЖА ===")
        print("Имя: \(characterName)")
        print("Характеристики: С\(strength) Л\(agility) В\(endurance) М\(wisdom) И\(intellect)")
        print("Всего очков: \(strength + agility + endurance + wisdom + intellect)")
        
        let character = PlayerCharacter(
            name: characterName.isEmpty ? username : characterName,
            strength: strength,
            agility: agility,
            endurance: endurance,
            wisdom: wisdom,
            intellect: intellect
        )
        
        // Регистрируем пользователя с персонажем
        let success = DataManager.shared.registerUser(username: username, password: password, character: character)
        print("Регистрация успешна: \(success)")
        
        if success {
            // Сохраняем персонажа отдельно
            DataManager.shared.saveCharacter(character)
            print("Персонаж сохранен")
            
            // Создаем игрока из персонажа
            viewModel.player1 = Player(from: character)
            print("Игрок создан: \(viewModel.player1.name)")
            
            // Переходим к главному меню
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                viewModel.gameState = .mainMenu
                print("Переход в главное меню")
                dismiss()
            }
        } else {
            errorMessage = "Не удалось создать аккаунт. Возможно, пользователь с таким именем уже существует."
            showErrorAlert = true
        }
    }
    
    private func updateCharacter() {
        if let currentCharacter = DataManager.shared.loadCharacter() {
            // Создаем нового персонажа с обновленными характеристиками
            var updatedCharacter = PlayerCharacter(
                name: characterName,
                strength: strength,
                agility: agility,
                endurance: endurance,
                wisdom: wisdom,
                intellect: intellect
            )
            
            // Сохраняем прогресс уровней и статистику из текущего персонажа
            updatedCharacter.level = currentCharacter.level
            updatedCharacter.experience = currentCharacter.experience
            updatedCharacter.availableStatPoints = currentCharacter.availableStatPoints
            updatedCharacter.battlesWon = currentCharacter.battlesWon
            updatedCharacter.battlesLost = currentCharacter.battlesLost
            updatedCharacter.totalDamageDealt = currentCharacter.totalDamageDealt
            updatedCharacter.totalDamageTaken = currentCharacter.totalDamageTaken
            updatedCharacter.creationDate = currentCharacter.creationDate
            
            // Сохраняем персонажа
            DataManager.shared.saveCharacter(updatedCharacter)
            
            // Обновляем данные в аккаунте, если пользователь зарегистрирован
            if DataManager.shared.getCurrentUser() != nil {
                _ = DataManager.shared.updateCurrentUserCharacter(updatedCharacter)
            }
            
            // Обновляем игрока
            viewModel.player1 = Player(from: updatedCharacter)
            dismiss()
        }
    }
    
    private func loadCurrentCharacter() {
        if let currentCharacter = DataManager.shared.loadCharacter() {
            // Режим редактирования существующего персонажа
            characterName = currentCharacter.name
            strength = currentCharacter.strength
            agility = currentCharacter.agility
            endurance = currentCharacter.endurance
            wisdom = currentCharacter.wisdom
            intellect = currentCharacter.intellect
            
            // ПРАВИЛЬНЫЙ расчет доступных очков для существующего персонажа
            let totalSpentPoints = strength + agility + endurance + wisdom + intellect
            let totalAvailablePoints = 50 // 25 базовых + 25 дополнительных
            
            // Доступные очки = Всего доступно - уже потрачено
            availablePoints = totalAvailablePoints - totalSpentPoints
            
            print("=== РЕДАКТИРОВАНИЕ СУЩЕСТВУЮЩЕГО ПЕРСОНАЖА ===")
            print("Имя: \(characterName)")
            print("Всего доступно очков: \(totalAvailablePoints)")
            print("Потрачено очков: \(totalSpentPoints)")
            print("Осталось очков: \(availablePoints)")
            print("Характеристики: С\(strength) Л\(agility) В\(endurance) М\(wisdom) И\(intellect)")
            
        } else if isRegistration {
            // Режим создания нового персонажа
            characterName = username.isEmpty ? "Новый герой" : username
            // Начинаем с 5 очков в каждой характеристике
            strength = 5
            agility = 5
            endurance = 5
            wisdom = 5
            intellect = 5
            // Доступно 25 очков для распределения
            availablePoints = 25
            
            print("=== СОЗДАНИЕ НОВОГО ПЕРСОНАЖА ===")
            print("Всего очков: 50 (25 базовых + 25 дополнительных)")
            print("Минимум на характеристики: 25 (5 на каждую)")
            print("Доступно для распределения: \(availablePoints)")
        }
    }
}

struct CharacteristicRow: View {
    let name: String
    @Binding var value: Int
    @Binding var availablePoints: Int
    let color: Color
    let minValue: Int
    
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
