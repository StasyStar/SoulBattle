import SwiftUI

struct MainCoordinatorView: View {
    @EnvironmentObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            // Фон
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Контент в зависимости от состояния
            switch viewModel.gameState {
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
    }
}
