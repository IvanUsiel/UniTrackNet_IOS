import Foundation

class BgpApiService {
    static let shared = BgpApiService()
    
    private let url = URL(
        
        ///Proucción
        //string: "http://200.33.150.46:2002/cgi-bin/unitrack_bgp.cgi"
        
        ///Simulación
        string: "https://private-b0c920-bgpsegmentoseuamexicoapi.apiary-mock.com/bgp/segmentos/todos"
    )!
    
    func fetchBgp(completion: @escaping (Result<SegmentosBgpResponseDto, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            
            if let err = error {
                completion(.failure(err))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            do {
                let dto = try JSONDecoder().decode(
                    SegmentosBgpResponseDto.self,
                    from: data
                )
                completion(.success(dto))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
