import SwiftUI

struct MainCoordinatorView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var showLogoutAlert = false
    
    var body: some View {
        ZStack {
            // Фон
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Контент в зависимости от состояния
            switch viewModel.gameState {
            case .authentication:
                AuthenticationView()
            case .characterCreation:
                CharacterCreationView()
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
    
    private func checkAuthenticationStatus() {
        if DataManager.shared.isUserLoggedIn() {
            if let character = DataManager.shared.loadCharacter() {
                viewModel.player1 = Player(from: character)
                viewModel.gameState = .mainMenu
            } else {
                viewModel.gameState = .authentication
            }
        } else {
            viewModel.gameState = .authentication
        }
    }
    
    private func logoutUser() {
        DataManager.shared.logoutUser()
        viewModel.gameState = .authentication
        viewModel.resetGame()
    }
}
