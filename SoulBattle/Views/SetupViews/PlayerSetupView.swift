import SwiftUI

struct PlayerSetupView: View {
    @EnvironmentObject var viewModel: GameViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Soul Battle")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Создайте своих воинов")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                
                VStack(spacing: 20) {
                    PlayerCardView(player: viewModel.player1, playerNumber: 1)
                    PlayerCardView(player: viewModel.player2, playerNumber: 2)
                }
                
                ActionButton(
                    title: "Начать битву душ",
                    action: { viewModel.startGame() },
                    isEnabled: true,
                    backgroundColor: .purple
                )
                
                PresetSelectionView()
            }
            .padding()
        }
    }
}

struct PlayerCardView: View {
    @ObservedObject var player: Player
    let playerNumber: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Душа \(playerNumber)")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(player.name)
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
            
            // Характеристики
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                StatView(name: "💪 Сила", value: player.strength, color: .red)
                StatView(name: "🏃 Ловкость", value: player.agility, color: .green)
                StatView(name: "❤️ Выносливость", value: player.endurance, color: .orange)
                StatView(name: "📚 Мудрость", value: player.wisdom, color: .blue)
                StatView(name: "🧠 Интеллект", value: player.intellect, color: .purple)
            }
            
            HealthBarView(health: player.health, maxHealth: player.maxHealth)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

struct StatView: View {
    let name: String
    let value: Int
    let color: Color
    
    var body: some View {
        HStack {
            Text(name)
                .font(.caption)
            Spacer()
            Text("\(value)")
                .font(.caption)
                .fontWeight(.bold)
        }
        .foregroundColor(.white)
        .padding(8)
        .background(color.opacity(0.3))
        .cornerRadius(8)
    }
}

struct PresetSelectionView: View {
    @EnvironmentObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Быстрые предустановки")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 10) {
                Button("Воин") { applyPreset(.warrior, to: viewModel.player1) }
                Button("Маг") { applyPreset(.mage, to: viewModel.player1) }
                Button("Разбойник") { applyPreset(.rogue, to: viewModel.player1) }
            }
            
            HStack(spacing: 10) {
                Button("Воин") { applyPreset(.warrior, to: viewModel.player2) }
                Button("Маг") { applyPreset(.mage, to: viewModel.player2) }
                Button("Разбойник") { applyPreset(.rogue, to: viewModel.player2) }
            }
        }
        .buttonStyle(PresetButtonStyle())
    }
    
    private func applyPreset(_ preset: CharacterPreset, to player: Player) {
        let newPlayer = Player(name: player.name, characterPreset: preset)
        player.strength = newPlayer.strength
        player.agility = newPlayer.agility
        player.endurance = newPlayer.endurance
        player.wisdom = newPlayer.wisdom
        player.intellect = newPlayer.intellect
    }
}

struct PresetButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
