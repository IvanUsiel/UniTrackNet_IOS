import Foundation

class TopologyRepository {

    func fetchAll(completion: @escaping (Result<TopologyResult, Error>) -> Void) {

        var bgpUiSegments:  [SegmentUiModel] = []
        var ospfUiSegments: [SegmentUiModel] = []

        var bgpTS:  String?
        var ospfTS: String?

        var errors: [Error] = []
        let group = DispatchGroup()

        // ---------- BGP ----------
        group.enter()
        BgpApiService.shared.fetchBgp { result in
            switch result {
            case .success(let dto):
                bgpTS = dto.timestamp
                bgpUiSegments = dto.segmentos.flatMap { wrapper in
                    wrapper.verificaciones.map { ver in
                        SegmentUiModel(
                            segmento:     wrapper.nombre,
                            origen:       ver.origen.nombre,
                            destino:      ver.vecino.nombre,
                            origenLat:    ver.origen.lat,
                            origenLng:    ver.origen.lon,
                            destinoLat:   ver.vecino.lat,
                            destinoLng:   ver.vecino.lon,
                            colorHex:     ver.estado_bgp == "ok" ? "#00FF00" : "#FF0000",
                            tipo:         .bgp,
                            estado:       ver.estado_bgp,
                            origenIP:     ver.origen.ip,
                            destinoIP:    ver.vecino.ip
                        )
                    }
                }
            case .failure(let error):
                errors.append(error)
            }
            group.leave()
        }

        // ---------- OSPF ----------
        group.enter()
        OspfApiService.shared.fetchOspf { result in
            switch result {
            case .success(let dto):
                ospfTS = dto.timestamp
                ospfUiSegments = dto.segmentos.flatMap { wrapper in
                    wrapper.verificaciones.map { ver in
                        SegmentUiModel(
                            segmento:     wrapper.nombre,
                            origen:       ver.origen.nombre,
                            destino:      ver.vecino.nombre,
                            origenLat:    ver.origen.lat,
                            origenLng:    ver.origen.lon,
                            destinoLat:   ver.vecino.lat,
                            destinoLng:   ver.vecino.lon,
                            colorHex:     ver.estado_ospf == "ok" ? "#00FF00" : "#FF0000",
                            tipo:         .ospf,
                            estado:       ver.estado_ospf,
                            origenIP:     ver.origen.ip,
                            destinoIP:    ver.vecino.ip
                        )
                    }
                }
            case .failure(let error):
                errors.append(error)
            }
            group.leave()
        }

        group.notify(queue: .main) {
            if let first = errors.first {
                completion(.failure(first))
            } else {
                let result = TopologyResult(
                    segments: bgpUiSegments + ospfUiSegments,
                    ospfTimestamp: ospfTS,
                    bgpTimestamp:  bgpTS
                )
                completion(.success(result))
            }
        }
    }
}
