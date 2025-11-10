import SwiftUI

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
                        
                        // Статистика
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
                    
                    // Действия
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
