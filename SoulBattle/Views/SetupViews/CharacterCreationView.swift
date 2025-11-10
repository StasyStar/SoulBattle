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
                    
                    // Имя персонажа
                    VStack(alignment: .leading) {
                        Text("Имя персонажа")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        
                        TextField("Введите имя", text: $characterName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    
                    // Очки характеристик
                    VStack {
                        Text("Доступно очков: \(availablePoints)")
                            .font(.headline)
                            .foregroundColor(availablePoints >= 0 ? .green : .red)
                            .padding(.bottom, 5)
                        
                        if availablePoints < 0 {
                            Text("Слишком много очков! Уберите \(abs(availablePoints))")
                                .foregroundColor(.red)
                                .font(.caption2)
                        }
                    }
                    
                    // Все характеристики
                    VStack(spacing: 10) {
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
                            saveCharacter()
                        }
                        .disabled(availablePoints != 0 || characterName.isEmpty)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(availablePoints == 0 && !characterName.isEmpty ? Color.green : Color.gray)
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
    }
    
    private func calculateAttackPower() -> String {
        let basePower = Double(strength + agility + wisdom + intellect) * 0.5
        return String(format: "%.1f", basePower)
    }
    
    private func calculateDefense() -> String {
        let baseDefense = Double(endurance) * 2.0
        return String(format: "%.1f", baseDefense)
    }
    
    private func saveCharacter() {
        let character = PlayerCharacter(
            name: characterName.isEmpty ? username : characterName,
            strength: strength,
            agility: agility,
            endurance: endurance,
            wisdom: wisdom,
            intellect: intellect
        )
        
        if isRegistration {
            let success = DataManager.shared.registerUser(username: username, password: password, character: character)
            if success {
                viewModel.player1 = Player(from: character)
                DispatchQueue.main.async {
                    viewModel.gameState = .mainMenu
                    dismiss()
                }
            }
        } else {
            DataManager.shared.saveCharacter(character)
            if DataManager.shared.getCurrentUser() != nil {
                _ = DataManager.shared.updateCurrentUserCharacter(character)
            }
            viewModel.player1 = Player(from: character)
            dismiss()
        }
    }
    
    private func loadCurrentCharacter() {
        if let current = DataManager.shared.loadCharacter() {
            characterName = current.name
            strength = current.strength
            agility = current.agility
            endurance = current.endurance
            wisdom = current.wisdom
            intellect = current.intellect
            
            let used = strength + agility + endurance + wisdom + intellect - 25
            availablePoints = 25 - used
        } else if isRegistration {
            characterName = username
        }
    }
}

struct CharacteristicRow: View {
    let name: String
    @Binding var value: Int
    @Binding var availablePoints: Int
    let color: Color
    
    var body: some View {
        HStack {
            Text(name)
                .foregroundColor(.white)
                .font(.caption)
                .frame(width: 110, alignment: .leading) // Увеличили ширину для полного слова
            
            Spacer()
            
            Text("\(value)")
                .foregroundColor(.white)
                .fontWeight(.bold)
                .font(.caption)
                .frame(width: 20)
            
            HStack(spacing: 8) {
                Button("-") {
                    if value > 1 {
                        value -= 1
                        availablePoints += 1
                    }
                }
                .buttonStyle(CharacteristicButtonStyle(color: color))
                .disabled(value <= 1)
                
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
