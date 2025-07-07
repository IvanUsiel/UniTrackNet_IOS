import UIKit
import MKRingProgressView

class PingGraphViewController: UIViewController {
    
    private let origen : RouterInfoPing
    private let destino: RouterInfoPing
    
    init(origen: RouterInfoPing, destino: RouterInfoPing) {
        self.origen  = origen
        self.destino = destino
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable) required init?(coder: NSCoder) { fatalError() }
    
    private let ringView   = RingProgressView()
    private let avgLabel   = UILabel()
    private let lossLabel  = UILabel()
    private let jitterLabel = UILabel()
    private let spinner    = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Ping \(origen.nombre) → \(destino.nombre)"
        setupUI()
        fetchAndDisplay()
    }
    
    private func setupUI() {
        ringView.startColor = UIColor(named: "UnitrackGreen") ?? .systemGreen
        ringView.endColor   = ringView.startColor
        ringView.backgroundRingColor = UIColor.darkGray.withAlphaComponent(0.3)
        ringView.ringWidth  = 24
        ringView.translatesAutoresizingMaskIntoConstraints = false
        
        [avgLabel, lossLabel, jitterLabel].forEach {
            $0.textColor = .white
            $0.textAlignment = .center
        }
        avgLabel.font    = .boldSystemFont(ofSize: 22)
        lossLabel.font   = .systemFont(ofSize: 14)
        jitterLabel.font = .systemFont(ofSize: 14)
        
        spinner.color = ringView.startColor
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        let infoStack = UIStackView(arrangedSubviews: [avgLabel, lossLabel, jitterLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 6
        infoStack.alignment = .center
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(ringView)
        view.addSubview(infoStack)
        view.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            ringView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ringView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            ringView.widthAnchor.constraint(equalToConstant: 250),
            ringView.heightAnchor.constraint(equalTo: ringView.widthAnchor),
            
            infoStack.topAnchor.constraint(equalTo: ringView.bottomAnchor, constant: 24),
            infoStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: ringView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: ringView.centerYAnchor),
        ])
    }
    
    private func fetchAndDisplay() {
        PingVerificationService.shared.ping(origen: origen, destino: destino) { [weak self] (result: Result<PingStats,Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                self.spinner.stopAnimating()
                
                switch result {
                case .success(let stats):
                    self.updateUI(with: stats)
                case .failure(let err):
                    self.showAlert("Ping error: \(err.localizedDescription)")
                }
            }
        }
    }
    
    private func updateUI(with stats: PingStats) {
        
        let quality = max(0, min(1, 1 - (stats.rttAvgMs / 250)))
        ringView.progress = quality
        avgLabel.text    = "\(Int(stats.rttAvgMs)) ms promedio"
        jitterLabel.text = "Jitter: \(Int(stats.jitterMs)) ms"
        
        let loss = stats.porcPerdida
        lossLabel.text  = "Pérdida: \(loss)%"
        if loss > 0 {
            ringView.startColor = .systemRed
            ringView.endColor   = .systemRed
        }
    }
}
