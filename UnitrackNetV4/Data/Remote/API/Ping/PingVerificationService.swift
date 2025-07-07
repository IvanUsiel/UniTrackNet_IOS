// PingVerificationService.swift
import Foundation

final class PingVerificationService {
    
    static let shared = PingVerificationService()
    
    ///Prudcción
    ///private let url = URL(string: "http://200.33.150.46:2002/cgi-bin/ping/verificar")!
    
    ///Simulación 
    private let url = URL(string: "https://private-87db0f-apiverificaciondeconectividadping.apiary-mock.com/ping/verificar")!
    
    func ping(origen: RouterInfoPing,
              destino: RouterInfoPing,
              completion: @escaping (Result<PingStats,Error>) -> Void) {
        
        let body = PingApiRequest(origen: origen,
                                  destino: destino,
                                  parametros: .init(paquetes: 20,
                                                    tamano_bytes: 64,
                                                    timeout_ms: 1000))
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: req) { data, _, err in
            if let err = err {
                completion(.failure(err)); return
            }
            guard let data else {
                completion(.failure(NSError(domain:"noData", code:0))); return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let apiResp = try decoder.decode(PingApiResponse.self, from: data)
                completion(.success(apiResp.resultado.estadisticas))
            } catch {
                completion(.failure(error))
            }
        }.resume()
        
    }
}
