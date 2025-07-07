struct Resultado: Decodable {
    let estado_ospf: String?   
    let estado_bgp:  String?
    let descripcion: String
    let salida_telnet: String
}
