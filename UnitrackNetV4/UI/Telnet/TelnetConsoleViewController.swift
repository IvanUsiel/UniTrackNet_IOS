import UIKit

class TelnetConsoleViewController: UIViewController {
    
    var origen:  RouterInfo!
    var destino: RouterInfo!
    var tipo:    SegmentoTipo = .ospf
    
    private let console       = UITextView()
    private let telnetButton  = UIButton(type: .system)
    private let spinner       = UIActivityIndicatorView(style: .large)
    private let consolePanel  = UIView()
    private let origenIcon  = UIImageView()
    private let destinoIcon = UIImageView()
    private let origenLabel  = UILabel()
    private let destinoLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Telnet"
        
        if presentingViewController != nil || navigationController?.viewControllers.first != self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "← Alarmas",
                style: .plain,
                target: self,
                action: #selector(closeSelf)
            )
        }
        setupUI()
        animatePanelIn()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        consolePanel.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        consolePanel.layer.cornerRadius = 16
        consolePanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(consolePanel)
        
        console.backgroundColor = .clear
        console.textColor = .green
        console.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        console.isEditable = false
        console.translatesAutoresizingMaskIntoConstraints = false
        
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(console)
        console.isScrollEnabled = false
        consolePanel.addSubview(scroll)
        
        telnetButton.setTitle("Telnet", for: .normal)
        telnetButton.setTitleColor(.white, for: .normal)
        telnetButton.layer.cornerRadius = 8
        telnetButton.layer.borderWidth = 2
        telnetButton.layer.borderColor = UIColor.unitrackGreen.cgColor
        telnetButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        telnetButton.addTarget(self, action: #selector(runTelnet), for: .touchUpInside)
        telnetButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(telnetButton)
        
        spinner.color = .systemYellow
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        
        [origenIcon, destinoIcon].forEach {
            $0.image = UIImage(named: "routertelnet")
            $0.contentMode = .scaleAspectFit
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.widthAnchor.constraint(equalToConstant: 28).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 28).isActive = true
        }
        
        [origenLabel, destinoLabel].forEach {
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 13, weight: .medium)
            $0.textAlignment = .center
            $0.numberOfLines = 2
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        origenLabel.text  = "\(origen.nombre)\n\(origen.ip)"
        destinoLabel.text = "\(destino.nombre)\n\(destino.ip)"
        
        let origenStack = UIStackView(arrangedSubviews: [origenIcon, origenLabel])
        origenStack.axis = .vertical
        origenStack.alignment = .center
        origenStack.spacing = 4
        origenStack.translatesAutoresizingMaskIntoConstraints = false
        
        let destinoStack = UIStackView(arrangedSubviews: [destinoIcon, destinoLabel])
        destinoStack.axis = .vertical
        destinoStack.alignment = .center
        destinoStack.spacing = 4
        destinoStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(origenStack)
        view.addSubview(destinoStack)
        
        NSLayoutConstraint.activate([
            consolePanel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            consolePanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            consolePanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            consolePanel.bottomAnchor.constraint(equalTo: telnetButton.topAnchor, constant: -20),
            
            scroll.topAnchor.constraint(equalTo: consolePanel.topAnchor, constant: 12),
            scroll.leadingAnchor.constraint(equalTo: consolePanel.leadingAnchor, constant: 12),
            scroll.trailingAnchor.constraint(equalTo: consolePanel.trailingAnchor, constant: -12),
            scroll.bottomAnchor.constraint(equalTo: consolePanel.bottomAnchor, constant: -12),
            
            console.topAnchor.constraint(equalTo: scroll.topAnchor),
            console.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            console.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            console.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            console.widthAnchor.constraint(equalTo: scroll.widthAnchor),
            
            telnetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            telnetButton.bottomAnchor.constraint(equalTo: origenStack.topAnchor, constant: -20),
            telnetButton.widthAnchor.constraint(equalToConstant: 140),
            telnetButton.heightAnchor.constraint(equalToConstant: 44),
            
            spinner.centerXAnchor.constraint(equalTo: telnetButton.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: telnetButton.centerYAnchor),
            
            origenStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            origenStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            
            destinoStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            destinoStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }
    
    private func animatePanelIn() {
        consolePanel.alpha = 0
        consolePanel.transform = CGAffineTransform(translationX: 0, y: 30)
        
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       options: [.curveEaseOut]) {
            self.consolePanel.alpha = 1
            self.consolePanel.transform = .identity
        }
    }
    
    @objc private func runTelnet() {
        telnetButton.isEnabled = false
        telnetButton.alpha = 0.3
        spinner.startAnimating()
        
        console.text = ""
        appendLine("Ejecutando Telnet \(tipo == .bgp ? "BGP" : "OSPF")…")
        simulateProgressLines()
        
        TelnetVerificationService.shared.verify(origen: origen,
                                                destino: destino,
                                                tipo: tipo) { [weak self] result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {   // espera a que “termine” la simulación
                guard let self else { return }
                self.spinner.stopAnimating()
                self.telnetButton.isEnabled = true
                self.telnetButton.alpha = 1
                
                switch result {
                case .success(let (estado, salida)):
                    let icon = estado == .ok ? "Ok" : "Error"
                    self.appendLine("\n\(icon) Resultado: \(estado.rawValue.uppercased())\n")
                    self.appendLine(salida)
                case .failure(let err):
                    self.appendLine("\n Error: \(err.localizedDescription)")
                }
            }
        }
    }
    
    private func simulateProgressLines() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.appendLine("→ Conectando con \(self.destino.ip)…")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let cmd = self.tipo == .bgp ? "show ip bgp summary" : "show ip ospf neighbor"
            self.appendLine("→ Enviando comando: \(cmd)")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.appendLine("← Esperando respuesta…")
        }
    }
    
    private func appendLine(_ line: String) {
        self.console.text += "\n\(line)"
    }
    
    @objc private func closeSelf() {
        if let nav = navigationController, nav.viewControllers.first != self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
