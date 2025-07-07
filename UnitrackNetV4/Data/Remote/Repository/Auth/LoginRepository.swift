class LoginRepository {
    func login(username: String, password: String, completion: @escaping (Result<LoginResponseDTO, Error>) -> Void) {
        let dto = LoginRequestDTO(username: username, password: password)
        AuthAPI.shared.login(request: dto, completion: completion)
    }
    
    func addIp(username: String, password: String, completion: @escaping (Result<AddIpResponseDto, Error>) -> Void) {
        let dto = AddIpRequestDto(username: username, password: password)
        AuthAPI.shared.addIp(dto, completion: completion)
    }

}
