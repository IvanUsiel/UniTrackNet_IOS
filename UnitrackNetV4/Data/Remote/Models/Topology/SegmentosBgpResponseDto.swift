struct SegmentosBgpResponseDto: Codable {
    let timestamp: String
    let segmentos: [SegmentoBgpWrapperDto]
}
