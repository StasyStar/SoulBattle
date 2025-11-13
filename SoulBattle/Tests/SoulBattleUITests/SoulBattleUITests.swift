import XCTest
@testable import SoulBattle

final class SoulBattleUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Устанавливаем аргументы для тестового режима
        app.launchArguments = ["--UITesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        // Очищаем тестовые данные после каждого теста
        let dataManager = DataManager.shared
        dataManager.clearTestData()
        
        app.terminate()
        app = nil
        try super.tearDownWithError()
    }

    @MainActor
    func testMainMenuAppears() throws {
        // Проверяем что главный экран появляется
        let soulBattleText = app.staticTexts["Soul Battle"]
        XCTAssertTrue(soulBattleText.waitForExistence(timeout: 10), "Main screen should appear")
    }
    
    @MainActor
    func testGuestLoginFlow() throws {
        // Нажимаем кнопку "Войти как гость"
        let guestButton = app.buttons["Войти как гость"]
        if guestButton.waitForExistence(timeout: 5) {
            guestButton.tap()
        }
        
        // Проверяем что попали на главный экран
        let mainMenu = app.staticTexts["Soul Battle"]
        XCTAssertTrue(mainMenu.waitForExistence(timeout: 5), "Should be on main menu after guest login")
        
        // Проверяем что есть кнопки режимов игры
        let pvpButton = app.buttons["Игрок vs Игрок"]
        let pveButton = app.buttons["Игрок vs Компьютер"]
        
        let pvpExists = pvpButton.waitForExistence(timeout: 3)
        let pveExists = pveButton.waitForExistence(timeout: 3)
        
        XCTAssertTrue(pvpExists, "PVP button should exist")
        XCTAssertTrue(pveExists, "PVE button should exist")
    }
    
    @MainActor
    func testNavigationToGameModes() throws {
        // Входим как гость если нужно
        if app.buttons["Войти как гость"].waitForExistence(timeout: 3) {
            app.buttons["Войти как гость"].tap()
        }
        
        // Нажимаем кнопку PVE режима
        let pveButton = app.buttons["Игрок vs Компьютер"]
        if pveButton.waitForExistence(timeout: 5) {
            pveButton.tap()
        }
        
        // Проверяем что перешли на экран подготовки
        let setupScreen = app.staticTexts["Начать битву"]
        let setupExists = setupScreen.waitForExistence(timeout: 5)
        XCTAssertTrue(setupExists, "Should navigate to battle setup screen")
        
        // Проверяем наличие кнопки начала битвы
        let startBattleButton = app.buttons["Начать битву"]
        XCTAssertTrue(startBattleButton.waitForExistence(timeout: 3), "Start battle button should exist")
    }
    
    @MainActor
    func testCharacterEditingNavigation() throws {
        // Входим как гость
        if app.buttons["Войти как гость"].waitForExistence(timeout: 3) {
            app.buttons["Войти как гость"].tap()
        }
        
        // Ищем и нажимаем кнопку редактирования персонажа
        let editButton = app.buttons["Редактировать персонажа"]
        if editButton.waitForExistence(timeout: 5) {
            editButton.tap()
        }
        
        // Проверяем что открылся экран создания/редактирования персонажа
        let editScreen = app.staticTexts["Создание персонажа"]
        let editExists = editScreen.waitForExistence(timeout: 5)
        
        XCTAssertTrue(editExists, "Character creation screen should open")
        
        // Проверяем наличие поля для имени персонажа
        let nameField = app.textFields["characterName"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3), "Character name field should exist")
    }
    
    @MainActor
    func testUserRegistrationFlow() throws {
        // Нажимаем кнопку регистрации если есть
        let registerButton = app.buttons["Нет аккаунта? Зарегистрируйтесь"]
        if registerButton.waitForExistence(timeout: 3) {
            registerButton.tap()
        }
        
        // Заполняем форму регистрации
        let usernameField = app.textFields["usernameField"]
        let passwordField = app.secureTextFields["passwordField"]
        let confirmPasswordField = app.secureTextFields["confirmPasswordField"]
        
        XCTAssertTrue(usernameField.waitForExistence(timeout: 3), "Username field should exist")
        XCTAssertTrue(passwordField.waitForExistence(timeout: 3), "Password field should exist")
        XCTAssertTrue(confirmPasswordField.waitForExistence(timeout: 3), "Confirm password field should exist")
        
        // Вводим тестовые данные
        usernameField.tap()
        usernameField.typeText("testuser\(Int.random(in: 1...1000))")
        
        passwordField.tap()
        passwordField.typeText("testpass")
        
        confirmPasswordField.tap()
        confirmPasswordField.typeText("testpass")
        
        // Нажимаем кнопку регистрации
        let registerSubmitButton = app.buttons["Зарегистрироваться"]
        if registerSubmitButton.waitForExistence(timeout: 3) {
            registerSubmitButton.tap()
        }
        
        // После регистрации должен открыться экран создания персонажа
        let characterCreationScreen = app.staticTexts["Создание персонажа"]
        let characterScreenExists = characterCreationScreen.waitForExistence(timeout: 5)
        
        XCTAssertTrue(characterScreenExists, "Should navigate to character creation after registration")
    }
    
    @MainActor
    func testBattleSelectionFlow() throws {
        // Входим как гость
        if app.buttons["Войти как гость"].waitForExistence(timeout: 3) {
            app.buttons["Войти как гость"].tap()
        }
        
        // Запускаем PVE игру
        let pveButton = app.buttons["Игрок vs Компьютер"]
        if pveButton.waitForExistence(timeout: 5) {
            pveButton.tap()
        }
        
        // Переходим к подготовке битвы
        let startBattleButton = app.buttons["Начать битву"]
        if startBattleButton.waitForExistence(timeout: 5) {
            startBattleButton.tap()
        }
        
        // Проверяем что попали на экран выбора атак и защит
        let roundText = app.staticTexts["Подготовка к раунду 1"]
        let roundExists = roundText.waitForExistence(timeout: 5)
        
        XCTAssertTrue(roundExists, "Should be on battle selection screen")
        
        // Проверяем наличие кнопки начала раунда
        let startRoundButton = app.buttons["Начать раунд"]
        XCTAssertTrue(startRoundButton.waitForExistence(timeout: 3), "Start round button should exist")
    }
    
    @MainActor
    func testUserLoginFlow() throws {
        // Сначала создаем тестового пользователя через DataManager
        let testUsername = "testuser\(Int.random(in: 1000...9999))"
        let testPassword = "testpass"
        
        let testCharacter = PlayerCharacter(
            name: testUsername,
            strength: 5,
            agility: 5,
            endurance: 5,
            wisdom: 5,
            intellect: 5
        )
        
        let success = DataManager.shared.registerUser(
            username: testUsername,
            password: testPassword,
            character: testCharacter
        )
        
        XCTAssertTrue(success, "Test user should be created successfully")
        
        // Перезапускаем приложение для чистого теста
        app.terminate()
        app.launchArguments = ["--UITesting"]
        app.launch()
        
        // Пытаемся войти
        let usernameField = app.textFields["usernameField"]
        let passwordField = app.secureTextFields["passwordField"]
        
        if usernameField.waitForExistence(timeout: 3) {
            usernameField.tap()
            usernameField.typeText(testUsername)
        }
        
        if passwordField.waitForExistence(timeout: 3) {
            passwordField.tap()
            passwordField.typeText(testPassword)
        }
        
        let loginButton = app.buttons["Войти"]
        if loginButton.waitForExistence(timeout: 3) {
            loginButton.tap()
        }
        
        // Проверяем успешный вход
        let mainMenu = app.staticTexts["Soul Battle"]
        XCTAssertTrue(mainMenu.waitForExistence(timeout: 5), "Should be on main menu after login")
    }
}
