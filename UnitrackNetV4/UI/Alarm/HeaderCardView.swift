import UIKit

class HeaderCardView: UIView {
    
    private let titleLabel  = UILabel()
    private let dateLabel   = UILabel()
    private let checkIcon   = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    func configure(title: String,
                   poleoText: String,
                   isHealthy: Bool) {
        
        titleLabel.text = title
        dateLabel.text  = poleoText
        
        layer.borderColor = isHealthy
        ? UIColor.systemGreen.cgColor
        : UIColor.systemRed.cgColor
        
        let symbol = isHealthy ? "checkmark.circle" : "exclamationmark.circle"
        checkIcon.image = UIImage(systemName: symbol)
        checkIcon.tintColor = isHealthy ? .systemGreen : .systemRed
    }
    
    private func setupUI() {
        backgroundColor  = UIColor(white: 0.1, alpha: 1)
        layer.cornerRadius = 12
        layer.borderWidth  = 3
        
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 1
        
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .lightGray
        dateLabel.numberOfLines = 0
        dateLabel.lineBreakMode = .byWordWrapping
        
        checkIcon.contentMode = .scaleAspectFit
        checkIcon.translatesAutoresizingMaskIntoConstraints = false
        checkIcon.setContentHuggingPriority(.required, for: .horizontal)
        
        let labelsStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = 4
        labelsStack.translatesAutoresizingMaskIntoConstraints = false
        
        let hStack = UIStackView(arrangedSubviews: [labelsStack, checkIcon])
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.spacing  = 8
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(hStack)
        
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            checkIcon.widthAnchor.constraint(equalToConstant: 80),
            checkIcon.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
}
