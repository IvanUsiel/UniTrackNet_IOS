enum SegmentoTipo: String, Codable {
    case bgp
    case ospf
    case mixto
}
struct SegmentUiModel: Codable {
    let segmento: String
    let origen: String
    let destino: String
    let origenLat: Double
    let origenLng: Double
    let destinoLat: Double
    let destinoLng: Double
    let colorHex: String
    let tipo: SegmentoTipo
    let estado: String
    let origenIP: String
    let destinoIP: String
}

