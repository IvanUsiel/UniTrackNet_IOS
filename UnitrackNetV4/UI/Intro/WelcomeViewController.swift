import UIKit
import MessageUI

class WelcomeViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    private let footerStack = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        let bgImage = UIImageView(image: UIImage(named: "image_mapintro"))
        bgImage.contentMode = .scaleAspectFill
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bgImage)
        
        let titleStack = UIStackView(arrangedSubviews: [
            makeLabel("UNI",  UIColor(named: "UnitrackGreen") ?? .green),
            makeLabel("TRACK", .gray),
            makeLabel("NET",  UIColor(named: "UnitrackGreen") ?? .green)
        ])
        titleStack.axis = .horizontal
        titleStack.alignment = .center
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleStack)
        
        let mainTitleStack = UIStackView(arrangedSubviews: [
            makeLabel("!Listo para", .white, size: 50),
            makeLabel("Comenzar!", UIColor(named: "UnitrackGreen") ?? .green, size: 50)
        ])
        mainTitleStack.axis = .vertical
        mainTitleStack.alignment = .center
        mainTitleStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainTitleStack)
        
        let signInButton = UIButton(type: .system)
        signInButton.setTitle("COMENZAR", for: .normal)
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        signInButton.layer.cornerRadius = 12
        signInButton.layer.borderWidth = 2
        signInButton.layer.borderColor = (UIColor(named: "UnitrackGreen") ?? .green).cgColor
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        view.addSubview(signInButton)
        
        let divider = UIView()
        divider.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        divider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(divider)
        
        let footerLabel = makeLabel("¿NO TIENES CUENTA?", .gray, size: 14)
        let contactBtn  = UIButton(type: .system)
        contactBtn.setTitle("CONTÁCTANOS", for: .normal)
        contactBtn.setTitleColor(UIColor(named: "UnitrackGreen") ?? .green, for: .normal)
        contactBtn.titleLabel?.font = .boldSystemFont(ofSize: 14)
        contactBtn.addTarget(self, action: #selector(handleContactUs), for: .touchUpInside)
        
        footerStack.axis = .vertical
        footerStack.alignment = .center
        footerStack.spacing = 4
        footerStack.translatesAutoresizingMaskIntoConstraints = false
        footerStack.addArrangedSubview(footerLabel)
        footerStack.addArrangedSubview(contactBtn)
        view.addSubview(footerStack)
        
        NSLayoutConstraint.activate([
            bgImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bgImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            bgImage.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            titleStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            mainTitleStack.topAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: 200),
            mainTitleStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            signInButton.topAnchor.constraint(equalTo: mainTitleStack.bottomAnchor, constant: 80),
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.widthAnchor.constraint(equalToConstant: 200),
            signInButton.heightAnchor.constraint(equalToConstant: 50),
            
            divider.bottomAnchor.constraint(equalTo: footerStack.topAnchor, constant: -10),
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            footerStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            footerStack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func makeLabel(_ text: String, _ color: UIColor, size: CGFloat = 24) -> UILabel {
        let lbl = UILabel()
        lbl.textColor = color
        lbl.text = text
        lbl.font = .boldSystemFont(ofSize: size)
        return lbl
    }
    
    // MARK: - Actions
    @objc private func handleSignIn() {
        let signInVC = SignInViewController()
        signInVC.modalPresentationStyle = .fullScreen
        present(signInVC, animated: true)
    }
    
    @objc private func handleContactUs() {
        guard MFMailComposeViewController.canSendMail() else {
            let a = UIAlertController(title: "Sin correo configurado",
                                      message: "Configura la app Mail para enviar correos.",
                                      preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "OK", style: .default))
            present(a, animated: true)
            return
        }
        
        let body = """
        <html>
          <body style="background-color:#0a0a0a; font-family:-apple-system, Helvetica, sans-serif; color:#ffffff; padding: 0; margin: 0;">
            <div style="max-width: 500px; margin: 40px auto; padding: 30px; background-color:#141414; border-radius:12px; border: 1px solid #00FF66;">
              
              <h1 style="text-align: center; font-size: 26px; margin-bottom: 10px;">
                <span style="color:#00FF66;">Uni</span><span style="color:#AAAAAA;">Track</span><span style="color:#00FF66;">Net</span>
              </h1>
              
              <hr style="border:0; height:1px; background:#333;">
              
              <p style="font-size: 16px; line-height: 1.6; color: #ffffff;">
                Hola equipo <strong style="color: #ffffff;">GSOP</strong>,
              </p>
              
              <p style="font-size: 16px; line-height: 1.6; color: #ffffff;">
                Solicito acceso a la aplicación móvil <strong style="color: #ffffff;">UniTrack Net</strong>.
                Agradezco su apoyo para generar mis credenciales o habilitar mi cuenta en <strong style="color: #ffffff;">Cisco ISE</strong>.
              </p>
              
              <p style="text-align: center; margin: 30px 0;">
                <span style="display: inline-block; background-color: #00FF66; color: black; padding: 12px 24px; border-radius: 8px; font-weight: bold; font-size: 15px;">
                  Solicitud acceso
                </span>
              </p>
              
              <hr style="border:0; height:1px; background:#333; margin: 30px 0;">
              
              <p style="text-align: center; font-size: 12px; color:#888;">
                Este mensaje fue generado automáticamente por la app iOS.
              </p>
            </div>
          </body>
        </html>
        """
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(["GSOP@reduno.com.mx"])
        mail.setSubject("Solicitud de acceso – UniTrackNet")
        mail.setMessageBody(body, isHTML: true)
        present(mail, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
    }
}
