import SwiftUI

struct CharacterCreationView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var characterName: String = ""
    @State private var availablePoints: Int = 25
    @State private var strength: Int = 5
    @State private var agility: Int = 5
    @State private var endurance: Int = 5
    @State private var wisdom: Int = 5
    @State private var intellect: Int = 5
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Создание персонажа")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Имя персонажа
                VStack(alignment: .leading, spacing: 10) {
                    Text("Имя персонажа")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("Введите имя", text: $characterName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(.black)
                }
                
                // Очки характеристик
                VStack(spacing: 15) {
                    Text("Очки характеристик: \(availablePoints)")
                        .font(.title2)
                        .foregroundColor(availablePoints >= 0 ? .green : .red)
                    
                    if availablePoints < 0 {
                        Text("Слишком много очков! Уберите \(abs(availablePoints))")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    StatDistributionView(
                        statName: "💪 Сила",
                        value: $strength,
                        availablePoints: $availablePoints,
                        color: .red
                    )
                    
                    StatDistributionView(
                        statName: "🏃 Ловкость",
                        value: $agility,
                        availablePoints: $availablePoints,
                        color: .green
                    )
                    
                    StatDistributionView(
                        statName: "❤️ Выносливость",
                        value: $endurance,
                        availablePoints: $availablePoints,
                        color: .orange
                    )
                    
                    StatDistributionView(
                        statName: "📚 Мудрость",
                        value: $wisdom,
                        availablePoints: $availablePoints,
                        color: .blue
                    )
                    
                    StatDistributionView(
                        statName: "🧠 Интеллект",
                        value: $intellect,
                        availablePoints: $availablePoints,
                        color: .purple
                    )
                }
                
                // Предпросмотр персонажа
                VStack(spacing: 10) {
                    Text("Предпросмотр")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 5) {
                        Text("Здоровье: \(String(format: "%.1f", 80.0 + Double(endurance) * 2.0))")
                        Text("Сила атаки: \(calculateAttackPower())")
                        Text("Защита: \(calculateDefense())")
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                }
                
                ActionButton(
                    title: "Создать персонажа",
                    action: createCharacter,
                    isEnabled: availablePoints == 0 && !characterName.isEmpty,
                    backgroundColor: .green
                )
                
                // Кнопка загрузки существующего персонажа
                if DataManager.shared.hasSavedCharacter() {
                    Button("Загрузить сохраненного персонажа") {
                        loadSavedCharacter()
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                }
            }
            .padding()
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
    
    private func createCharacter() {
        let character = PlayerCharacter(
            name: characterName,
            strength: strength,
            agility: agility,
            endurance: endurance,
            wisdom: wisdom,
            intellect: intellect
        )
        
        // Сохраняем персонажа
        DataManager.shared.saveCharacter(character)
        
        // Создаем игрока из персонажа
        viewModel.player1 = Player(from: character)
        
        // Переходим к выбору режима игры
        viewModel.gameState = .mainMenu
    }
    
    private func loadSavedCharacter() {
        if let savedCharacter = DataManager.shared.loadCharacter() {
            viewModel.player1 = Player(from: savedCharacter)
            viewModel.gameState = .mainMenu
        }
    }
}

struct StatDistributionView: View {
    let statName: String
    @Binding var value: Int
    @Binding var availablePoints: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(statName)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(value)")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 30)
                
                HStack(spacing: 5) {
                    Button("-") {
                        if value > 1 {
                            value -= 1
                            availablePoints += 1
                        }
                    }
                    .buttonStyle(StatButtonStyle(color: color))
                    .disabled(value <= 1)
                    
                    Button("+") {
                        if availablePoints > 0 {
                            value += 1
                            availablePoints -= 1
                        }
                    }
                    .buttonStyle(StatButtonStyle(color: color))
                    .disabled(availablePoints <= 0)
                }
            }
            
            // Прогресс бар
            ProgressView(value: Double(value), total: 10)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
        }
    }
}

struct StatButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(width: 30, height: 30)
            .background(color)
            .cornerRadius(6)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}
