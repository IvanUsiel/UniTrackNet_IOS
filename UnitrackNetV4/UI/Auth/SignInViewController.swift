import UIKit
import MessageUI


class SignInViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private var emailField: UITextField!
    private var passwordField: UITextField!
    private var rememberMeSwitch: UISwitch!
    private let faceIdImage = UIImageView(image: UIImage(systemName: "faceid"))
    private let signInButton = UIButton(type: .system)
    private var biometricAvailable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        buildHierarchy()
        applyConstraints()
        populateIfRemembered()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if biometricAvailable,
           SecurePrefs.isBiometricEnabled(),
           SecurePrefs.loadCredentials() != nil {
            handleBiometricAuth()
        }
    }
    
    private func configureView() {
        view.backgroundColor = .black
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        faceIdImage.tintColor = .gray
        faceIdImage.contentMode = .scaleAspectFit
        faceIdImage.isUserInteractionEnabled = true
        faceIdImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        faceIdImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        faceIdImage.accessibilityLabel = "Iniciar sesión con Face ID"
        faceIdImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBiometricAuth)))
        
        signInButton.setTitle("INICIAR SESIÓN", for: .normal)
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        signInButton.layer.cornerRadius = 10
        signInButton.layer.borderWidth = 2
        signInButton.layer.borderColor = UIColor(named: "UnitrackGreen")?.cgColor
        signInButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        signInButton.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        signInButton.isEnabled = true
        
        emailField = makeTextField(placeholder: "E-mail / Username")
        passwordField = makeTextField(placeholder: "Contraseña", isSecure: true)
        addPasswordToggle()
        
        rememberMeSwitch = UISwitch()
        let rememberLabel = UILabel()
        rememberLabel.text = "Recordar"
        rememberLabel.textColor = .white
        rememberLabel.font = .preferredFont(forTextStyle: .body)
        rememberLabel.adjustsFontForContentSizeCategory = true
        let rememberStack = UIStackView(arrangedSubviews: [rememberMeSwitch, rememberLabel])
        rememberStack.axis = .horizontal
        rememberStack.spacing = 8
        rememberStack.alignment = .center
        
        let titleLabel = makeTitleStyled()
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Desarrollado por GSOP"
        subtitleLabel.textColor = .lightGray
        subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textAlignment = .center
        
        let dividerStack = makeDividerWithText("O INICIA SESIÓN CON")
        
        let footerLabel = UILabel()
        footerLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self,
                                          action: #selector(handleContactSgSord))
        footerLabel.addGestureRecognizer(tap)
        let contactText = NSMutableAttributedString(string: "¿NO TIENES UNA CUENTA ISE? ", attributes: [.foregroundColor: UIColor.gray])
        contactText.append(NSAttributedString(string: "CONTACTA SG-SORD", attributes: [.foregroundColor: UIColor(named: "UnitrackGreen") ?? .green]))
        footerLabel.attributedText = contactText
        footerLabel.font = .preferredFont(forTextStyle: .footnote)
        footerLabel.adjustsFontForContentSizeCategory = true
        footerLabel.textAlignment = .center
        footerLabel.numberOfLines = 0
        
        [titleLabel, subtitleLabel,
         emailField, passwordField,
         rememberStack, signInButton,
         dividerStack, faceIdImage].forEach { contentStack.addArrangedSubview($0) }
        
        contentStack.setCustomSpacing(40, after: faceIdImage)
        contentStack.addArrangedSubview(footerLabel)
    }
    
    private func buildHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 30),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -30),
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -60) 
        ])
    }
    
    private func makeTextField(placeholder: String, isSecure: Bool = false) -> UITextField {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.6)]
        )
        tf.isSecureTextEntry = isSecure
        tf.borderStyle = .none
        tf.backgroundColor = UIColor(white: 0.15, alpha: 1)
        tf.textColor = .white
        tf.layer.cornerRadius = 10
        tf.setLeftPaddingPoints(12)
        tf.heightAnchor.constraint(equalToConstant: 50).isActive = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }
    
    private func addPasswordToggle() {
        let toggleButton = UIButton(type: .custom)
        toggleButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        toggleButton.tintColor = .lightGray
        toggleButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        passwordField.rightView = toggleButton
        passwordField.rightViewMode = .always
    }
    
    private func makeDividerWithText(_ text: String) -> UIStackView {
        let line1 = UIView()
        line1.backgroundColor = .darkGray
        line1.translatesAutoresizingMaskIntoConstraints = false
        line1.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        let label = UILabel()
        label.text = text
        label.textColor = .gray
        label.font = .preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        
        let line2 = UIView()
        line2.backgroundColor = .darkGray
        line2.translatesAutoresizingMaskIntoConstraints = false
        line2.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        let stack = UIStackView(arrangedSubviews: [line1, label, line2])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        line1.widthAnchor.constraint(equalTo: line2.widthAnchor).isActive = true
        return stack
    }
    
    private func makeTitleStyled() -> UILabel {
        let label = UILabel()
        let full = NSMutableAttributedString()
        full.append(NSAttributedString(string: "¡Bienvenido!", attributes: [.foregroundColor: UIColor.white]))
        full.append(NSAttributedString(string: "Uni", attributes: [.foregroundColor: UIColor(named: "UnitrackGreen") ?? .green]))
        full.append(NSAttributedString(string: "Track", attributes: [.foregroundColor: UIColor.lightGray]))
        full.append(NSAttributedString(string: " Net", attributes: [.foregroundColor: UIColor(named: "UnitrackGreen") ?? .green]))
        label.attributedText = full
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    @objc private func togglePasswordVisibility() {
        passwordField.isSecureTextEntry.toggle()
        let imageName = passwordField.isSecureTextEntry ? "eye.fill" : "eye.slash.fill"
        if let button = passwordField.rightView as? UIButton {
            button.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
    
    @objc func handleSignIn() {
        guard let username = emailField.text, !username.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert("Por favor, introduzca ambos campos")
            return
        }
        
        signInButton.isEnabled = false
        let loading = showLoading(message: "Autenticando…")
        
        let repository = LoginRepository()
        repository.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                self.signInButton.isEnabled = true
                self.hideLoading(alert: loading)
                switch result {
                    
                case .success(let response):
                    if response.status == "success" {
                        
                        if self.rememberMeSwitch.isOn {
                            SecurePrefs.saveCredentials(username: username, password: password)
                        }
                        
                        if UserProfileStorage.load() == nil {
                            
                            UserAPI.shared.fetchUserProfile(username: username) { apiResult in
                                DispatchQueue.main.async {
                                    switch apiResult {
                                        
                                    case .success(let dto):
                                        let fmt = DateFormatter()
                                        fmt.dateStyle = .medium
                                        fmt.timeStyle = .short
                                        
                                        let previousLoginString = UserDefaults.standard.string(forKey: "last_login")
                                        var previousLoginDate: Date?
                                        if let prev = previousLoginString {
                                            previousLoginDate = fmt.date(from: prev)
                                        }
                                        
                                        UserDefaults.standard.set(fmt.string(from: Date()), forKey: "last_login")
                                        
                                        if var profile = UserProfileStorage.load() {
                                            profile.lastLogin = previousLoginDate ?? Date()
                                            profile.currentIP = self.getIPAddress() ?? "N/A"
                                            UserProfileStorage.save(profile)
                                        } else {
                                            let profile = UserProfile(
                                                username: dto.username,
                                                fullname: dto.fullname,
                                                email: dto.email,
                                                role: dto.role,
                                                currentIP: self.getIPAddress() ?? "N/A",
                                                lastLogin: previousLoginDate ?? Date(),
                                                isFaceIDEnabled: SecurePrefs.isBiometricEnabled(),
                                                avatarImageData: nil
                                            )
                                            UserProfileStorage.save(profile)
                                        }
                                        
                                    case .failure(let error):
                                        print("No se pudo obtener perfil de ISE:", error.localizedDescription)
                                    }
                                    
                                    let fmt = DateFormatter()
                                    fmt.dateStyle = .medium; fmt.timeStyle = .short
                                    UserDefaults.standard.setValue(fmt.string(from: Date()), forKey: "last_login")
                                    
                                    self.hideLoading(alert: loading)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        self.goToAbout()
                                    }
                                }
                            }
                            
                        } else {
                            let fmt = DateFormatter()
                            fmt.dateStyle = .medium; fmt.timeStyle = .short
                            UserDefaults.standard.setValue(fmt.string(from: Date()), forKey: "last_login")
                            self.hideLoading(alert: loading)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.goToAbout()
                            }
                        }
                        
                    } else {
                        ApiErrorMapper.handleError(
                            errorType: response.error_type,
                            message: response.message,
                            on: self,
                            username: username,
                            password: password
                        )
                    }
                    
                case .failure(let error):
                    self.showAlert("Error: \(error.localizedDescription)")
                }
                
            }
        }
    }
    
    @objc private func handleContactSgSord() {
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: "Sin correo configurado",
                                          message: "Configura la app Mail para enviar correos.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let body = """
        <html>
          <body style="background-color:#0a0a0a; font-family:-apple-system, Helvetica, sans-serif; color:#ffffff; padding:0; margin:0;">
            <div style="max-width:500px; margin:40px auto; padding:30px; background-color:#141414; border-radius:12px; border:1px solid #00FF66;">
              <h1 style="text-align:center; font-size:26px; margin-bottom:10px;">
                <span style="color:#00FF66;">Uni</span><span style="color:#AAAAAA;">Track</span><span style="color:#00FF66;">Net</span>
              </h1>
              <hr style="border:0; height:1px; background:#333;">
              <p style="font-size:16px; line-height:1.6;">
                Hola equipo <strong style="color:#ffffff;">SG-SORD</strong>,
              </p>
              <p style="font-size:16px; line-height:1.6;">
                Solicito la creación o habilitación de mis <strong>credenciales Cisco ISE</strong>
                para acceder a la aplicación móvil <strong>UniTrack Net</strong>.
                Agradezco su apoyo.
              </p>
              <p style="text-align:center; margin:30px 0;">
                <span style="display:inline-block; background-color:#00FF66; color:black; padding:12px 24px; border-radius:8px; font-weight:bold; font-size:15px;">
                  Solicitud ISE
                </span>
              </p>
              <hr style="border:0; height:1px; background:#333; margin:30px 0;">
              <p style="text-align:center; font-size:12px; color:#888;">
                Este mensaje fue generado automáticamente por la app iOS.
              </p>
            </div>
          </body>
        </html>
        """

        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(["sg_sord@uninet.com.mx"])
        mail.setSubject("Solicitud de credenciales Cisco ISE – UniTrack Net")
        mail.setMessageBody(body, isHTML: true)
        present(mail, animated: true)
    }

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
    }

    
    
    
    @objc func handleBiometricAuth() {
        guard let (user, pass) = SecurePrefs.loadCredentials() else { return }
        
        BiometricHelper.authenticateUser { result in
            switch result {
            case .success:
                self.loginWithStoredCredentials(username: user, password: pass)
            case .failure(let error):
                self.showAlert("Error de autenticación biométrica: \(error)")
            }
        }
    }
    
    private func goToAbout() {
        let aboutVC = AboutViewController()
        aboutVC.modalPresentationStyle = .fullScreen
        self.present(aboutVC, animated: true)
    }
    
    private func loginWithStoredCredentials(username: String, password: String) {
        let loading = showLoading(message: "Autenticando…")
        let repo = LoginRepository()
        
        repo.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                self.hideLoading(alert: loading)
                
                switch result {
                case .success(let resp) where resp.status == "success":
                    let about = AboutViewController()
                    about.modalPresentationStyle = .fullScreen
                    self.present(about, animated: true)
                    
                case .success(let resp):
                    ApiErrorMapper.handleError(
                        errorType: resp.error_type,
                        message: resp.message,
                        on: self,
                        username: username,
                        password: password
                    )
                    
                case .failure(let error):
                    self.showAlert("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    
    private func autoLoginIfStoredCredentialsExist() {
        if let (username, password) = SecurePrefs.loadCredentials() {
            let loading = showLoading(message: "Autenticando con biometría…")
            let repository = LoginRepository()
            repository.login(username: username, password: password) { result in
                DispatchQueue.main.async {
                    self.hideLoading(alert: loading)
                    switch result {
                    case .success(let response):
                        if response.status == "success" {
                            if self.presentedViewController == nil {
                                self.present(AboutViewController(), animated: true)
                            }
                        } else {
                            ApiErrorMapper.handleError(
                                errorType: response.error_type,
                                message: response.message,
                                on: self,
                                username: username,
                                password: password
                            )
                        }
                    case .failure(let error):
                        self.showAlert("Error: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            showAlert("No se encontraron credenciales almacenadas.")
        }
    }
    
    private func populateIfRemembered() {
        if let (savedUsername, savedPassword) = SecurePrefs.loadCredentials() {
            emailField.text = savedUsername
            passwordField.text = savedPassword
            rememberMeSwitch.isOn = true
        }
    }
    
    private func getIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifaddr) == 0, let first = ifaddr {
            for ptr in sequence(first: first, next: { $0.pointee.ifa_next }) {
                let ifa = ptr.pointee
                if ifa.ifa_addr.pointee.sa_family == UInt8(AF_INET),
                   let name = String(validatingUTF8: ifa.ifa_name),
                   name == "en0" { // Wi-Fi
                    var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(ifa.ifa_addr,
                                socklen_t(ifa.ifa_addr.pointee.sa_len),
                                &host, socklen_t(host.count),
                                nil, 0, NI_NUMERICHOST)
                    address = String(cString: host)
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 50))
        leftView = paddingView
        leftViewMode = .always
    }
    
}
