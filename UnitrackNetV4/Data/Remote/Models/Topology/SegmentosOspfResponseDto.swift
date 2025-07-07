struct SegmentosOspfResponseDto: Codable {
    let timestamp: String
    let segmentos: [SegmentoOspfWrapperDto]
}
