import Foundation

final class TelnetVerificationService {
    
    static let shared = TelnetVerificationService()
    
    //Producción
    //private let bgpURL  = URL(string:"http://200.33.150.46:2002/cgi-bin/bgp_check.cgi")!
    //private let ospfURL = URL(string:"http://200.33.150.46:2002/cgi-bin/ospf_check.cgi")!
    
    //Simulación
    private let bgpURL  = URL(string:"https://private-083bd1-apiverificacionbgppuntoapuntotelnet.apiary-mock.com/bgp/verificar")!
    private let ospfURL = URL(string:"https://private-bbeecd-apiverificacionospfpuntoapuntotelnet.apiary-mock.com/ospf/verificar")!

    
    func verify(origen: RouterInfo,
                destino: RouterInfo,
                tipo: SegmentoTipo,
                completion: @escaping (Result<(TelnetResult, String), Error>) -> Void) {
        
        let url  = (tipo == .bgp) ? bgpURL : ospfURL
        let body = TelnetApiRequest(origen: origen, vecino: destino)
        
        var req = URLRequest(url: url)
        req.httpMethod  = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody    = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: req) { data, _, err in
            if let err = err {
                completion(.failure(err))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "noData", code: 0)))
                return
            }
            
            do {
                let apiResp = try JSONDecoder().decode(TelnetAPIResponse.self, from: data)
                let estado  = apiResp.resultado.estado_bgp ?? apiResp.resultado.estado_ospf ?? "fail"
                let result: TelnetResult = (estado.lowercased() == "ok") ? .ok : .fail
                completion(.success((result, apiResp.resultado.salida_telnet)))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
