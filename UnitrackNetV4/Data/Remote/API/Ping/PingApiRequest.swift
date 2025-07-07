import Foundation

struct PingApiRequest: Encodable {
    let origen: RouterInfoPing
    let destino: RouterInfoPing
    let parametros: PingParams
}
