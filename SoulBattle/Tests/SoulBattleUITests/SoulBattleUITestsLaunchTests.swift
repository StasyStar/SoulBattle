import XCTest

final class SoulBattleUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--UITesting"]
        app.launch()

        // Проверяем что приложение запустилось и показывает основной контент
        let soulBattleText = app.staticTexts["Soul Battle"]
        let exists = soulBattleText.waitForExistence(timeout: 10)
        XCTAssertTrue(exists, "App should launch and show main content")
        
        // Делаем скриншот для отчета
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        // Это измеряет время запуска приложения
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
