import Foundation

class OspfApiService {
    static let shared = OspfApiService()
    
    private let url = URL(
        ///Producción
        //string: "http://200.33.150.46:2002/cgi-bin/unitrack_ospf.cgi"
        
        ///Simulación
        string: "https://private-87799c-apiospfeuamex.apiary-mock.com/ospf/segmentos/todos"
    )!
    
    func fetchOspf(completion: @escaping (Result<SegmentosOspfResponseDto, Error>) -> Void) {
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
                    SegmentosOspfResponseDto.self,
                    from: data
                )
                completion(.success(dto))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
