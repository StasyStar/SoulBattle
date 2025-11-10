import SwiftUI

struct MainCoordinatorView: View {
    @EnvironmentObject var viewModel: GameViewModel
    
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
            case .characterCreation:
                CharacterCreationView()
            case .mainMenu:
                MainMenuView()
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
            // При запуске проверяем есть ли сохраненный персонаж
            if !DataManager.shared.hasSavedCharacter() {
                viewModel.gameState = .characterCreation
            }
        }
    }
}
