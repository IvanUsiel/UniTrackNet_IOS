struct SegmentoOspfWrapperDto: Codable {
    let nombre: String
    let verificaciones: [VerificacionOspfDto]
}
