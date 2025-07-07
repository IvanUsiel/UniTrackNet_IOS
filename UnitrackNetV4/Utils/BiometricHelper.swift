import LocalAuthentication

class BiometricHelper {
    
    enum BiometricError: Error {
        case notAvailable
        case failed
        case userCancel
        case unknown
    }
    
    static func authenticateUser(reason: String = "Autenticarse para continuar", completion: @escaping (Result<Void, BiometricError>) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        completion(.success(()))
                    } else {
                        let code = (authError as? LAError)?.code
                        switch code {
                        case .userCancel:
                            completion(.failure(.userCancel))
                        default:
                            completion(.failure(.failed))
                        }
                    }
                }
            }
        } else {
            completion(.failure(.notAvailable))
        }
    }
    
    static func biometricType() -> String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        default: return "None"
        }
    }
}
