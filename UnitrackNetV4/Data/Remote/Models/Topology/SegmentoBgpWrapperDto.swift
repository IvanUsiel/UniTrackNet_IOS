struct SegmentoBgpWrapperDto: Codable {
    let nombre: String
    let verificaciones: [VerificacionBgpDto]
}
