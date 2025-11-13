import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @Binding var showLogoutAlert: Bool
    @State private var showUserProfile = false
    @State private var showCharacterEditor = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Soul Battle")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .purple, radius: 10)
                        
                        if let currentUser = DataManager.shared.getCurrentUser() {
                            Text("Привет, \(currentUser)!")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                        } else if let character = viewModel.player1.savedCharacter {
                            Text("Привет, \(character.name)!")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                        } else {
                            Text("Привет, Гость!")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { showUserProfile.toggle() }) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                VStack {
                    if UIImage(named: "battle_mages") != nil {
                        Image("battle_mages")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(15)
                            .shadow(radius: 10)
                    } else {
                        // Fallback если изображение не найдено
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(height: 200)
                    }
                    
                    Text("Битва Душ")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.top, 5)
                }
                .padding(.horizontal)
                
                if let character = viewModel.player1.savedCharacter {
                    VStack(spacing: 8) {
                        Text("Статистика персонажа")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 25) {
                            VStack {
                                Text("\(character.battlesWon)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                Text("Победы")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            VStack {
                                Text("\(character.battlesLost)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                Text("Поражения")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            VStack {
                                Text("\(String(format: "%.1f", character.winRate))%")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(character.winRate > 50 ? .green : .orange)
                                Text("Побед %")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
                
                VStack(spacing: 15) {
                    MenuButton(
                        title: "Игрок vs Игрок",
                        subtitle: "Сразитесь с другом",
                        icon: "person.2",
                        color: .blue,
                        action: { viewModel.startPVPGame() }
                    )
                    .accessibilityIdentifier("pvpButton")
                    
                    MenuButton(
                        title: "Игрок vs Компьютер",
                        subtitle: "Бой против ИИ",
                        icon: "desktopcomputer",
                        color: .green,
                        action: { viewModel.startPVEGame() }
                    )
                    .accessibilityIdentifier("pveButton")
                    
                    Button("Редактировать персонажа") {
                        showCharacterEditor = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showUserProfile) {
            UserProfileView(showLogoutAlert: $showLogoutAlert)
        }
        .sheet(isPresented: $showCharacterEditor) {
            CharacterCreationView(isRegistration: false)
        }
    }
}
