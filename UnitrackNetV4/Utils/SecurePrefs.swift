import Foundation

enum SecurePrefs {
    private enum Key {
        static let username         = "savedUsername"
        static let password         = "savedPassword"
        static let biometricEnabled = "biometricEnabled"
    }
    
    static func saveCredentials(username: String, password: String) {
        UserDefaults.standard.set(username, forKey: Key.username)
        UserDefaults.standard.set(password, forKey: Key.password)
    }
    
    static func loadCredentials() -> (String, String)? {
        guard
            let user = UserDefaults.standard.string(forKey: Key.username),
            let pass = UserDefaults.standard.string(forKey: Key.password)
        else { return nil }
        return (user, pass)
    }
    
    static func clearCredentials() {
        UserDefaults.standard.removeObject(forKey: Key.username)
        UserDefaults.standard.removeObject(forKey: Key.password)
        setBiometricEnabled(false)
    }
    
    static func setBiometricEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: Key.biometricEnabled)
    }
    static func isBiometricEnabled() -> Bool {
        UserDefaults.standard.bool(forKey: Key.biometricEnabled)
    }
}
