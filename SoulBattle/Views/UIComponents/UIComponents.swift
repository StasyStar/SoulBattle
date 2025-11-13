import SwiftUI

struct ActionButton: View {
    let title: String
        let action: () -> Void
        var isEnabled: Bool = true
        var backgroundColor: Color = .blue
        var size: ButtonSize = .medium
        var accessibilityId: String? = nil
    
    enum ButtonSize {
        case small, medium, large
        
        var font: Font {
            switch self {
            case .small: return .subheadline
            case .medium: return .headline
            case .large: return .title3
            }
        }
        
        var verticalPadding: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 12
            case .large: return 16
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 15
            case .large: return 18
            }
        }
        
        var shadowRadius: CGFloat {
            switch self {
            case .small: return 3
            case .medium: return 5
            case .large: return 8
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(size.font)
                .foregroundColor(.white)
                .padding(.vertical, size.verticalPadding)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: isEnabled ? [backgroundColor, .purple] : [.gray]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(size.cornerRadius)
                .shadow(radius: isEnabled ? size.shadowRadius : 0)
        }
        .disabled(!isEnabled)
        .padding(.horizontal)
        .accessibilityIdentifier(accessibilityId ?? "")
    }
}

struct MenuButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [color, color.opacity(0.7)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(15)
            .shadow(color: color, radius: 5)
        }
    }
}

struct AttackButton: View {
    let attackType: AttackType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: attackType.icon)
                Text(attackType.rawValue)
                    .font(.caption)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding(10)
            .background(isSelected ? Color.red.opacity(0.3) : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .red : .primary)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.red : Color.gray, lineWidth: 1)
            )
        }
    }
}

struct DefenseButton: View {
    let defenseType: DefenseType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: defenseType.icon)
                Text(defenseType.rawValue)
                    .font(.caption)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding(10)
            .background(isSelected ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .blue : .primary)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 1)
            )
        }
    }
}

struct CompactAttackButton: View {
    let attackType: AttackType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: attackType.icon)
                    .font(.system(size: 12))
                Text(attackType.rawValue)
                    .font(.system(size: 10))
                    .lineLimit(1)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 12))
                }
            }
            .padding(6)
            .background(isSelected ? Color.red.opacity(0.4) : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .red : .primary)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? Color.red : Color.gray, lineWidth: 1)
            )
        }
    }
}

struct CompactDefenseButton: View {
    let defenseType: DefenseType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: defenseType.icon)
                    .font(.system(size: 12))
                Text(defenseType.rawValue)
                    .font(.system(size: 10))
                    .lineLimit(1)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 12))
                }
            }
            .padding(6)
            .background(isSelected ? Color.blue.opacity(0.4) : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .blue : .primary)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 1)
            )
        }
    }
}

struct HealthBarView: View {
    let health: Double
    let maxHealth: Double
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: 120, height: 12)
                    .opacity(0.3)
                    .foregroundColor(.red)
                
                Rectangle()
                    .frame(width: CGFloat(health / maxHealth * 120), height: 12)
                    .foregroundColor(health > 30 ? .green : .red)
                    .animation(.easeInOut, value: health)
            }
            .cornerRadius(6)
        }
    }
}

struct VSView: View {
    var body: some View {
        Text("⚔️")
            .font(.largeTitle)
            .rotationEffect(.degrees(-10))
            .shadow(color: .yellow, radius: 2)
    }
}

struct BattleLogView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Ход битвы:")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(gameViewModel.gameLog.suffix(15), id: \.self) { logEntry in
                        // Пропускаем строку о начале игры
                        if !logEntry.contains("Игра началась!") && !logEntry.contains("против") {
                            Text(logEntry)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                        }
                    }
                }
            }
            .frame(height: 100)
            .padding(8)
            .background(Color.black.opacity(0.3))
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }
}

struct UserProfileView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var showLogoutAlert: Bool
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let stats = DataManager.shared.getUserStatistics() {
                        // Информация о пользователе
                        VStack(spacing: 15) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.purple)
                            
                            Text(stats.username)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Зарегистрирован: \(stats.registrationDate, formatter: dateFormatter)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("Время в игре: \(stats.playTime)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Статистика игрока")
                                .font(.headline)
                            
                            StatRow(title: "Всего битв", value: "\(stats.battlesPlayed)")
                            StatRow(title: "Победы", value: "\(stats.character.battlesWon)")
                            StatRow(title: "Поражения", value: "\(stats.character.battlesLost)")
                            StatRow(title: "Процент побед", value: "\(String(format: "%.1f", stats.character.winRate))%")
                            StatRow(title: "Всего урона", value: "\(String(format: "%.0f", stats.character.totalDamageDealt))")
                            StatRow(title: "Получено урона", value: "\(String(format: "%.0f", stats.character.totalDamageTaken))")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                    }
                    
                    VStack(spacing: 10) {
                        Button("Выйти из аккаунта") {
                            showLogoutAlert = true
                            dismiss()
                        }
                        .foregroundColor(.blue)
                        
                        Button("Удалить аккаунт") {
                            showDeleteAlert = true
                        }
                        .foregroundColor(.red)
                    }
                }
                .padding()
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .alert("Удаление аккаунта", isPresented: $showDeleteAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Удалить", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("Все данные аккаунта будут безвозвратно удалены. Это действие нельзя отменить.")
            }
        }
    }
    
    private func deleteAccount() {
        if DataManager.shared.deleteUserAccount() {
            viewModel.gameState = .authentication
            viewModel.resetGame()
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    formatter.locale = Locale(identifier: "ru_RU")
    return formatter
}()
