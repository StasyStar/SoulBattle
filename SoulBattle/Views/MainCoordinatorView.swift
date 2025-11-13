import SwiftUI

struct MainCoordinatorView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var showLogoutAlert = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            switch viewModel.gameState {
            case .authentication:
                AuthenticationView()
            case .characterCreation:
                CharacterCreationView(isRegistration: true)
            case .mainMenu:
                MainMenuView(showLogoutAlert: $showLogoutAlert)
            case .setup:
                PlayerSetupView()
            case .selection:
                BattleSelectionView()
            case .battle:
                BattleView()
            case .result:
                GameResultView()
            }
        }
        .onAppear {
            checkAuthenticationStatus()
        }
        .alert("Выход из аккаунта", isPresented: $showLogoutAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Выйти", role: .destructive) {
                logoutUser()
            }
        } message: {
            Text("Все данные текущего аккаунта будут сохранены. Вы уверены, что хотите выйти?")
        }
    }
    
    private func checkAuthenticationStatus() {}
    
    private func logoutUser() {
        viewModel.logoutUser()
    }
}
