struct PingResult: Decodable {
    let estadoPing   : String
    let descripcion  : String
    let origenIp     : String
    let destinoIp    : String
    let estadisticas : PingStats
    let salidaPing   : String
    let timestamp    : String
}

