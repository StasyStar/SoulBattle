import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var isLoginMode = true
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Заголовок
                VStack(spacing: 10) {
                    Text("Soul Battle")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .purple, radius: 10)
                    
                    Text(isLoginMode ? "Вход в аккаунт" : "Регистрация")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Форма
                VStack(spacing: 20) {
                    TextField("Имя пользователя", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .accessibilityIdentifier("usernameField")
                    
                    SecureField("Пароль", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityIdentifier("passwordField")
                    
                    if !isLoginMode {
                        SecureField("Подтвердите пароль", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .accessibilityIdentifier("confirmPasswordField")
                    }
                }
                
                // Основные кнопки
                VStack(spacing: 15) {
                    ActionButton(
                        title: isLoginMode ? "Войти" : "Зарегистрироваться",
                        action: handleAuthentication,
                        isEnabled: isFormValid,
                        backgroundColor: .purple,
                        accessibilityId: isLoginMode ? "loginButton" : "registerButton"
                    )
                    
                    Button(isLoginMode ? "Нет аккаунта? Зарегистрируйтесь" : "Уже есть аккаунт? Войдите") {
                        switchAuthMode()
                    }
                    .foregroundColor(.white)
                    
                    // Гость
                    if isLoginMode {
                        Button("Войти как гость") {
                            viewModel.enterAsGuest()
                        }
                        .foregroundColor(.white.opacity(0.8))
                        .accessibilityIdentifier("guestButton")
                    }
                }
                
                // Информация о режиме гостя
                if isLoginMode {
                    VStack(spacing: 10) {
                        Text("Гостевой режим")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Данные сохраняются только на этом устройстве. Для синхронизации между устройствами создайте аккаунт.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .alert("Ошибка", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var isFormValid: Bool {
        if username.isEmpty || password.isEmpty {
            return false
        }
        
        if !isLoginMode {
            return password == confirmPassword && password.count >= 3
        }
        
        return true
    }
    
    private func handleAuthentication() {
        if isLoginMode {
            loginUser()
        } else {
            registerUser()
        }
    }
    
    private func loginUser() {
        if viewModel.loginUser(username: username, password: password) {
        } else {
            showError("Неверное имя пользователя или пароль")
        }
    }
    
    private func registerUser() {
        if viewModel.registerUser(username: username, password: password) {
        } else {
            showError("Пользователь с таким именем уже существует")
        }
    }
    
    private func switchAuthMode() {
        isLoginMode.toggle()
        username = ""
        password = ""
        confirmPassword = ""
    }
    
    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}
