import Foundation

class AuthAPI {
    static let shared = AuthAPI()
    
    ///Producción
    //private let baseURL = "http://200.33.150.46:2002/cgi-bin/auth_movil_tacacs.cgi"
    
    ///Simulación
    private let baseURL = "https://private-08d36c-apiautenticaciontacacsise.apiary-mock.com/tacacs/autenticar"
    
    func login(request: LoginRequestDTO,
               completion: @escaping (Result<LoginResponseDTO, Error>) -> Void) {
        
        guard let url = URL(string: baseURL) else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            completion(.failure(error)); return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            
            if let urlErr = error as? URLError {
                let offline = LoginResponseDTO(
                    status: "error",
                    code: 0,
                    message: urlErr.localizedDescription,
                    error_type: "network_error",
                    server: "unreachable"
                )
                DispatchQueue.main.async { completion(.success(offline)) }
                return
            }
            
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data else {
                let noData = LoginResponseDTO(
                    status: "error",
                    code: 0,
                    message: "No data from server.",
                    error_type: "network_error",
                    server: "unreachable"
                )
                DispatchQueue.main.async { completion(.success(noData)) }
                return
            }
            
            if let jsonStr = String(data: data, encoding: .utf8) {
                print("[LOGIN RESPONSE RAW]: \(jsonStr)")
            }
            do {
                let result = try JSONDecoder().decode(LoginResponseDTO.self, from: data)
                print("[LOGIN DECODED]: status=\(result.status) error_type=\(result.error_type ?? "nil")")
                DispatchQueue.main.async { completion(.success(result)) }
            } catch {
                print("[LOGIN DECODING ERROR]: \(error)")
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
    
    func addIp(_ request: AddIpRequestDto,
               completion: @escaping (Result<AddIpResponseDto, Error>) -> Void) {
        
        guard let url = URL(string: "\(baseURL)cgi-bin/auth_movil_tacacs_addip.cgi") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 999))); return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            completion(.failure(error)); return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            
            if let urlErr = error as? URLError {
                let offline = AddIpResponseDto(
                    status: "error",
                    code: 0,
                    message: urlErr.localizedDescription,
                    error_type: "network_error",
                    server: "unreachable"
                )
                DispatchQueue.main.async { completion(.success(offline)) }
                return
            }
            
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else {
                let noData = AddIpResponseDto(
                    status: "error",
                    code: 0,
                    message: "No data from server.",
                    error_type: "network_error",
                    server: "unreachable"
                )
                DispatchQueue.main.async { completion(.success(noData)) }
                return
            }
            do {
                let decoded = try JSONDecoder().decode(AddIpResponseDto.self, from: data)
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}
