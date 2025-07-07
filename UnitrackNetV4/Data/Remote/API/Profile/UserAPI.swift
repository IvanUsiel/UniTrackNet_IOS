import Foundation

final class UserAPI {
    
    static let shared = UserAPI()
    private init() {}
    
    //Prudcción
    //private let baseURL = URL(string: "http://200.33.150.46:2002/cgi-bin/ise/iseprofile")!
                              
    //Simulación
    private let baseURL = URL(string: "https://private-a7530e-iseinformationsimulate.apiary-mock.com/")!
    
    func fetchUserProfile(
        username: String,
        completion: @escaping (Result<UserProfileDTO, Error>) -> Void
    ) {
        let endpoint = baseURL.appendingPathComponent("usuario/\(username)")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }
            
            if let http = response as? HTTPURLResponse, http.statusCode == 404 {
                let notFound = NSError(
                    domain: "UserAPI",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "Usuario no encontrado"]
                )
                return completion(.failure(notFound))
            }
            
            guard let data = data else {
                return completion(.failure(
                    NSError(domain: "UserAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Sin datos del servidor"]))
                )
            }
            
            do {
                let dto = try JSONDecoder().decode(UserProfileDTO.self, from: data)
                completion(.success(dto))
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
    }
}
