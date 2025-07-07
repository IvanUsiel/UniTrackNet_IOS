import UIKit

struct ApiErrorMapper {
    
    static func handleError(
        errorType: String?,
        message: String?,
        on viewController: UIViewController,
        username: String? = nil,
        password: String? = nil,
        retryAction: (() -> Void)? = nil
    ) {
        guard let error = errorType else {
            viewController.showAlert("No se pudo procesar la respuesta del servidor.")
            return
        }
        
        print("[ApiErrorMapper] Error recibido: \(error)")
        
        switch error {
            
        case "invalid_credentials":
            let alert = UIAlertController(title: "Error", message: "Usuario o contraseña incorrectos.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            presentSafely(alert, on: viewController)
            
        case "unauthorized_ip":
            let alert = UIAlertController(
                title: "IP VPN no autorizada",
                message: "Tu IP VPN no está permitida.\n¿Quieres solicitar acceso?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Sí", style: .default, handler: { _ in
                let ipVC = AddIpViewController()
                ipVC.prefilledUsername = username
                ipVC.prefilledPassword = password
                viewController.present(ipVC, animated: true)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel))
            presentSafely(alert, on: viewController)
            
        case "no_ise_available":
            let alert = UIAlertController(title: "Error", message: "Ningún servidor ISE está disponible.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            presentSafely(alert, on: viewController)
            
        case "server_error":
            let alert = UIAlertController(title: "Error", message: "El servidor tuvo un problema inesperado. Intenta más tarde.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            presentSafely(alert, on: viewController)
            
        case "timeout":
            let alert = UIAlertController(title: "Error", message: "Tiempo de espera agotado. Revisa tu conexión e inténtalo de nuevo.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            presentSafely(alert, on: viewController)
            
        case "network_error":
            let alert = UIAlertController(title: "Error", message: "Sin conexión. Revisa tu red VPN.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            presentSafely(alert, on: viewController)
            
        case "invalid_json":
            let alert = UIAlertController(title: "Error", message: "El formato de datos enviado es inválido.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            presentSafely(alert, on: viewController)
            
        case "missing_fields":
            let alert = UIAlertController(title: "Error", message: "Faltan campos obligatorios.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            presentSafely(alert, on: viewController)
            
        case "ip_missing":
            let alert = UIAlertController(title: "Error", message: "No se pudo detectar tu IP.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            presentSafely(alert, on: viewController)
            
        case "invalid_request":
            let alert = UIAlertController(title: "Error", message: "La solicitud no es válida.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            presentSafely(alert, on: viewController)
            
        default:
            let fallbackMessage = message ?? "Ha ocurrido un error desconocido."
            let alert = UIAlertController(title: "Error", message: fallbackMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            presentSafely(alert, on: viewController)
        }
        
    }
    
    private static func presentSafely(_ alert: UIAlertController, on vc: UIViewController) {
        if vc.presentedViewController == nil {
            vc.present(alert, animated: true)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                vc.present(alert, animated: true)
            }
        }
    }
}
