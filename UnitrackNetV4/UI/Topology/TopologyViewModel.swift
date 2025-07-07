import Foundation

class TopologyViewModel {
    
    private let repository = TopologyRepository()
    
    private(set) var segments:       [SegmentUiModel] = []
    private(set) var ospfTimestamp:  String?
    private(set) var bgpTimestamp:   String?
    
    var onDataLoaded: (([SegmentUiModel]) -> Void)?
    var onError: ((String) -> Void)?
    
    func fetchData() {
        repository.fetchAll { [weak self] (result: Result<TopologyResult, Error>) in
            switch result {
            case .success(let topo):
                self?.segments       = topo.segments
                self?.ospfTimestamp  = topo.ospfTimestamp
                self?.bgpTimestamp   = topo.bgpTimestamp
                self?.onDataLoaded?(topo.segments)
            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }
}
