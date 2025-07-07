import UIKit

class AddIpViewController: UIViewController {
    
    var prefilledUsername: String?
    var prefilledPassword: String?
    
    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()
    private let headerImage  = UIImageView(image: UIImage(named: "image_mapintro"))
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let sendButton    = UIButton(type: .system)
    private var keyboardObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        configureHeaderImage()
        configureScrollAndStack()
        configureFields()
        configureSendButton()
        layoutUI()
        registerKeyboardNotifications()
    }
    
    deinit { if let ob = keyboardObserver { NotificationCenter.default.removeObserver(ob) } }
    
    private func configureHeaderImage() {
        headerImage.contentMode = .scaleAspectFill
        headerImage.translatesAutoresizingMaskIntoConstraints = false
        // Gradient overlay para mejor legibilidad del texto encima
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.clear.cgColor]
        gradient.locations = [0, 1]
        gradient.frame = UIScreen.main.bounds
        headerImage.layer.addSublayer(gradient)
    }
    
    private func configureScrollAndStack() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 30),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -30),
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -60)
        ])
        
        contentStack.addArrangedSubview(headerImage)
        headerImage.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.35).isActive = true
    }
    
    private func configureFields() {
        usernameField.configureStyled(placeholder: "ID/Username", text: prefilledUsername)
        passwordField.configureStyled(placeholder: "Contraseña", text: prefilledPassword, secure: true)
        addEyeToggle(to: passwordField)
        
        contentStack.addArrangedSubview(usernameField)
        contentStack.addArrangedSubview(passwordField)
    }
    
    private func configureSendButton() {
        sendButton.setTitle("enviar", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        sendButton.layer.cornerRadius = 10
        sendButton.layer.borderWidth = 2
        sendButton.layer.borderColor = (UIColor(named: "UnitrackGreen") ?? .systemGreen).cgColor
        sendButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        contentStack.addArrangedSubview(sendButton)
    }
    
    private func layoutUI() {
        let titleLabel = UILabel()
        titleLabel.text = "Agregar VPN IP"
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontForContentSizeCategory = true
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Ingresa correctamente tu usuario y\ncontraseña para dar de alta tu VPN IP"
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = UIColor(named: "UnitrackGreen") ?? .systemGreen
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 2
        subtitleLabel.adjustsFontForContentSizeCategory = true
        
        contentStack.insertArrangedSubview(titleLabel, at: 1)
        contentStack.insertArrangedSubview(subtitleLabel, at: 2)
    }
    
    private func addEyeToggle(to textField: UITextField) {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        button.tintColor = .lightGray
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        textField.rightView = button
        textField.rightViewMode = .always
    }
    
    @objc private func togglePasswordVisibility() {
        passwordField.isSecureTextEntry.toggle()
        let imageName = passwordField.isSecureTextEntry ? "eye.fill" : "eye.slash.fill"
        if let button = passwordField.rightView as? UIButton {
            button.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
    
    private func registerKeyboardNotifications() {
        keyboardObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main) { [weak self] notif in
                guard let self = self,
                      let userInfo = notif.userInfo,
                      let frameEnd = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
                let keyboardVisible = frameEnd.origin.y < UIScreen.main.bounds.height
                let bottomInset = keyboardVisible ? frameEnd.height - view.safeAreaInsets.bottom : 0
                scrollView.contentInset.bottom = bottomInset + 20
                scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
            }
    }
    
    @objc private func handleSend() {
        guard let username = usernameField.text, !username.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert("Por favor completa ambos campos.")
            return
        }
        
        sendButton.isEnabled = false
        let loading = showLoading(message: "Registrando IP…")
        
        let request = AddIpRequestDto(username: username, password: password)
        AuthAPI.shared.addIp(request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoading(alert: loading)
                self.sendButton.isEnabled = true
                
                switch result {
                case .success(let response) where response.status == "success":
                    self.showSuccessAndDismiss()
                case .success(let response):
                    ApiErrorMapper.handleError(errorType: response.error_type,
                                               message: response.message,
                                               on: self,
                                               username: username,
                                               password: password)
                case .failure(let error):
                    self.showAlert("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showSuccessAndDismiss() {
        let alert = UIAlertController(title: "Éxito",
                                      message: "Tu IP fue registrada correctamente. Intenta iniciar sesión nuevamente.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}

extension UITextField {
    func configureStyled(placeholder: String, text: String? = nil, secure: Bool = false) {
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.6)])
        self.text = text
        self.isSecureTextEntry = secure
        self.backgroundColor = UIColor(white: 0.2, alpha: 1)
        self.textColor = .white
        self.borderStyle = .none
        self.layer.cornerRadius = 10
        self.setLeftPaddingPoints(12)
        self.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.adjustsFontForContentSizeCategory = true
    }
}
