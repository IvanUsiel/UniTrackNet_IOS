struct PingStats: Decodable {
    let paquetesEnviados    : Int
    let paquetesRecibidos   : Int
    let paquetesPerdidos    : Int
    let porcPerdida         : Int
    let rttMinMs            : Double
    let rttAvgMs            : Double
    let rttMaxMs            : Double
    let rttStddevMs         : Double
    let jitterMs            : Double
}
