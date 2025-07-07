struct VerificacionOspfDto: Codable {
    let origen: Router
    let vecino: Router
    let estado_ospf: String
}
