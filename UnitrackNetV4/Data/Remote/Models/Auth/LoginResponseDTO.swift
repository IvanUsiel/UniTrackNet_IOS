struct LoginResponseDTO: Codable {
    let status: String
    let code: Int
    let message: String
    let error_type: String?
    let server: String?
}
