import Foundation

extension Notification.Name {
    static let alarmsUpdated = Notification.Name("alarmsUpdated")
}

class AlarmCenter {
    
    static let shared = AlarmCenter()
    private let repo = TopologyRepository()
    private var isRefreshing = false
    private init() {}
    
    func refresh() {
        guard !isRefreshing else { return }
        isRefreshing = true
        print("AlarmCenter → refresh")
        
        repo.fetchAll { [weak self] result in
            guard let self = self else { return }
            defer { self.isRefreshing = false }
            
            switch result {
            case .success(let topo):
                let segs = topo.segments
                let err  = segs.filter { $0.estado.lowercased() != "ok" }.count
                print("ejecutando alarmsUpdated (\(err))")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .alarmsUpdated,
                        object: nil,
                        userInfo: ["count": err,
                                   "segments": segs])
                }
            case .failure(let error):
                print("AlarmCenter error: \(error)")
            }
        }
    }
    
    func refresh(completion: @escaping (Int) -> Void) {
        repo.fetchAll { result in
            switch result {
            case .success(let topo):
                let segs      = topo.segments
                let errCount  = segs.filter { $0.estado.lowercased() != "ok" }.count
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .alarmsUpdated,
                        object: nil,
                        userInfo: ["count": errCount,
                                   "segmentos": segs]
                    )
                    completion(errCount)
                }
                
            case .failure(let e):
                print("AlarmCenter error: \(e)")
                DispatchQueue.main.async { completion(0) }
            }
        }
    }
}

