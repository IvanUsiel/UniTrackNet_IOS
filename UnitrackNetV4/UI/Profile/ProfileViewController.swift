import UIKit
import Darwin

class ProfileViewController: UIViewController {
    
    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()
    private let avatarContainer = UIView()
    private let avatarImageView = UIImageView()
    private let editAvatarBtn   = UIButton(type: .system)
    private let fullnameLbl  = UILabel()
    private let emailLbl     = UILabel()
    private let usernameLbl  = UILabel()
    private let roleLbl      = UILabel()
    private let ipLbl        = UILabel()
    private let lastLoginLbl = UILabel()
    private let logoutBtn    = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        layout()
        populate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populate()
    }
    
    private func setupUI() {
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 28
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 75
        avatarImageView.tintColor = .darkGray
        avatarImageView.image = UIImage(systemName: "person.crop.circle")
        
        editAvatarBtn.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        editAvatarBtn.tintColor = .systemGray6
        editAvatarBtn.backgroundColor = view.backgroundColor
        editAvatarBtn.layer.cornerRadius = 14
        editAvatarBtn.addTarget(self, action: #selector(selectNewAvatar), for: .touchUpInside)
        
        avatarContainer.translatesAutoresizingMaskIntoConstraints = false
        avatarContainer.addSubview(avatarImageView)
        avatarContainer.addSubview(editAvatarBtn)
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        editAvatarBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 150),
            avatarImageView.heightAnchor.constraint(equalToConstant: 150),
            avatarImageView.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            
            editAvatarBtn.widthAnchor.constraint(equalToConstant: 28),
            editAvatarBtn.heightAnchor.constraint(equalToConstant: 28),
            editAvatarBtn.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 4),
            editAvatarBtn.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 4)
        ])
        
        [fullnameLbl, emailLbl,
         usernameLbl, roleLbl,
         ipLbl, lastLoginLbl].forEach {
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 16)
            $0.numberOfLines = 0
        }
        
        fullnameLbl.font = .boldSystemFont(ofSize: 22)
        fullnameLbl.textAlignment = .center
        
        emailLbl.textColor = .gray
        emailLbl.textAlignment = .center
        
        let iseHeader = sectionHeader("Datos ISE")
        let actHeader = sectionHeader("Actividad")
        
        var config = UIButton.Configuration.plain()
        config.title = "Borrar sesión"
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 24, bottom: 6, trailing: 24)
        
        logoutBtn.configuration = config
        logoutBtn.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        logoutBtn.backgroundColor = .black
        logoutBtn.layer.borderWidth = 2
        logoutBtn.layer.borderColor = (UIColor(named: "UnitrackGreen") ?? .systemGreen).cgColor
        logoutBtn.layer.cornerRadius = 8
        logoutBtn.addTarget(self, action: #selector(confirmLogout), for: .touchUpInside)
        
        let iseBox = box(with: vertical(labels: [usernameLbl, roleLbl]))
        let actBox = box(with: vertical(labels: [lastLoginLbl, ipLbl]))
        
        let headerStack = UIStackView(arrangedSubviews: [fullnameLbl, emailLbl])
        headerStack.axis = .vertical
        headerStack.spacing = 6
        headerStack.alignment = .center
        
        [avatarContainer,
         headerStack,
         iseHeader, iseBox,
         actHeader, actBox].forEach { contentStack.addArrangedSubview($0) }
    }
    
    private func sectionHeader(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.textColor = .lightGray
        lbl.font = .systemFont(ofSize: 14, weight: .semibold)
        return lbl
    }
    
    private func vertical(labels: [UILabel]) -> UIStackView {
        let s = UIStackView(arrangedSubviews: labels)
        s.axis = .vertical
        s.spacing = 6
        s.alignment = .leading
        return s
    }
    
    private func box(with content: UIView) -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.15, alpha: 1)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -16),
            content.topAnchor.constraint(equalTo: v.topAnchor, constant: 16),
            content.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -16)
        ])
        return v
    }
    
    private func layout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        view.addSubview(logoutBtn)
        logoutBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: logoutBtn.topAnchor),
            
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            
            logoutBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            
            avatarContainer.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func populate() {
        guard let p = UserProfileStorage.load() else { return }
        fullnameLbl.text  = p.fullname
        emailLbl.text     = p.email
        usernameLbl.text  = "Usuario: \(p.username)"
        roleLbl.text      = "Rol: \(p.role)"
        
        if let img = p.avatarImage {
            avatarImageView.image = img
        }
        
        let stored = UserDefaults.standard.string(forKey: "last_login") ?? "—"
        lastLoginLbl.text = "Último acceso: \(stored)"
        ipLbl.text        = "IP actual: \(getIPAddress() ?? p.currentIP)"
    }
    
    @objc private func confirmLogout() {
        let alert = UIAlertController(title: "Borrar sesión",
                                      message: "¿Seguro que quieres borrar tu sesión?",
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Borrar", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        if let pop = alert.popoverPresentationController {
            pop.sourceView = logoutBtn
            pop.sourceRect = logoutBtn.bounds
        }
        present(alert, animated: true)
    }
    
    private func performLogout() {
        SecurePrefs.clearCredentials()
        UserProfileStorage.clear()
        dismiss(animated: true)
    }
    
    @objc private func selectNewAvatar() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    private func getIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifaddr) == 0, let first = ifaddr {
            for ptr in sequence(first: first, next: { $0.pointee.ifa_next }) {
                let ifa = ptr.pointee
                if ifa.ifa_addr.pointee.sa_family == UInt8(AF_INET),
                   let name = String(validatingUTF8: ifa.ifa_name),
                   name == "en0" {
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

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let img = (info[.editedImage] ?? info[.originalImage]) as? UIImage,
              var profile = UserProfileStorage.load() else { return }
        profile.avatarImage = img
        UserProfileStorage.save(profile)
        avatarImageView.image = img
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
