import SwiftUI

@main
struct SoulBattleApp: App {
    @StateObject private var gameViewModel = GameViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainCoordinatorView()
                .environmentObject(gameViewModel)
        }
    }
}
