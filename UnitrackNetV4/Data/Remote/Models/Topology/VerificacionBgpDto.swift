struct VerificacionBgpDto: Codable {
    let origen: Router
    let vecino: Router
    let estado_bgp: String
}
