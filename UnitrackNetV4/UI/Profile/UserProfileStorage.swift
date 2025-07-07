import Foundation

struct UserProfileStorage {
    
    private static let key = "stored_user_profile"
    static func save(_ profile: UserProfile) {
        do {
            let data = try JSONEncoder().encode(profile)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Error al guardar el perfil:", error)
        }
    }
    
    static func load() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode(UserProfile.self, from: data)
        } catch {
            print("Error al leer el perfil:", error)
            return nil
        }
    }
    
    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
