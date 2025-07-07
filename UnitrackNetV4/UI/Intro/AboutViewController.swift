import UIKit

class AboutViewController: UIViewController {
    
    private let imageView         = UIImageView(image: UIImage(named: "image_worldintro"))
    private let welcomeLabel      = UILabel()
    private let unitrackLabel     = UILabel()
    private let descriptionLabel  = UILabel()
    private let greenLine         = UIView()
    private let startButton       = UIButton(type: .system)
    private let contentStack      = UIStackView()
    private let scrollView        = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        layoutUI()
        animateEntrance()
    }
    
    private func setupUI() {
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addParallax(to: imageView)
        
        welcomeLabel.text = "Bienvenido"
        welcomeLabel.font = .preferredFont(forTextStyle: .title3)
        welcomeLabel.textColor = .white
        welcomeLabel.textAlignment = .center
        welcomeLabel.adjustsFontForContentSizeCategory = true
        
        let attr = NSMutableAttributedString()
        attr.append(NSAttributedString(
            string: "UNI",
            attributes: [.foregroundColor: UIColor(named: "UnitrackGreen") ?? .green])
        )
        attr.append(NSAttributedString(
            string: "TRACK",
            attributes: [.foregroundColor: UIColor.lightGray])
        )
        attr.append(NSAttributedString(
            string: "NET",
            attributes: [.foregroundColor: UIColor(named: "UnitrackGreen") ?? .green])
        )
        unitrackLabel.attributedText = attr
        unitrackLabel.font = .boldSystemFont(ofSize: 30)
        unitrackLabel.textAlignment = .center
        unitrackLabel.adjustsFontSizeToFitWidth = true
        unitrackLabel.minimumScaleFactor = 0.8
        
        descriptionLabel.text = """
        UniTrackNet es una plataforma de monitoreo y administración de redes diseñada para optimizar el control de enlaces OSPF y sesiones BGP de la red de UNINET, especialmente aquellos que conectan a EE. UU. y México.
        """
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .lightGray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.adjustsFontForContentSizeCategory = true
        
        greenLine.backgroundColor = UIColor(named: "UnitrackGreen") ?? .green
        greenLine.translatesAutoresizingMaskIntoConstraints = false
        greenLine.heightAnchor.constraint(equalToConstant: 2).isActive = true
        greenLine.widthAnchor.constraint(equalToConstant: 40).isActive = true
        greenLine.layer.cornerRadius = 1
        
        var config = UIButton.Configuration.plain()
        config.title = "Empezar"
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 32, bottom: 12, trailing: 32)
        
        startButton.configuration = config
        startButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        startButton.layer.cornerRadius = 20
        startButton.layer.borderWidth  = 2
        startButton.layer.borderColor  = (UIColor(named: "UnitrackGreen") ?? .green).cgColor
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 24
        
        [welcomeLabel, unitrackLabel, descriptionLabel, greenLine, startButton]
            .forEach { contentStack.addArrangedSubview($0) }
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        view.addSubview(scrollView)
        view.addSubview(imageView)
    }
    
    private func layoutUI() {
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.45)
        ])
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 30),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -30),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -60)
        ])
    }
    
    @objc private func startTapped() {
        let tabBar = MainTabBarController()
        tabBar.modalPresentationStyle = .fullScreen
        present(tabBar, animated: true)
    }
    
    private func animateEntrance() {
        [welcomeLabel, unitrackLabel, descriptionLabel, greenLine, startButton].forEach {
            $0.alpha = 0
        }
        for (index, view) in [welcomeLabel, unitrackLabel, descriptionLabel, greenLine, startButton].enumerated() {
            UIView.animate(withDuration: 0.6,
                           delay: 0.15 * Double(index),
                           options: [.curveEaseOut],
                           animations: { view.alpha = 1 },
                           completion: nil)
        }
    }
    
    private func addParallax(to view: UIView) {
        let amount: CGFloat = 20
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x",type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue =  amount
        
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y",
                                                   type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue =  amount
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        
        view.addMotionEffect(group)
    }
    
}

private extension UIMotionEffectGroup {
    func then(_ block: (UIMotionEffectGroup) -> Void) -> UIMotionEffectGroup {
        block(self)
        return self
    }
}
