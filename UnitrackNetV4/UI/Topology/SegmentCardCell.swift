import UIKit

class SegmentCardCell: UICollectionViewCell {
    static let reuseID = "SegmentCardCell"
    
    private let iconView   = UIImageView()
    private let nameLabel  = UILabel()
    private let countLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:)") }
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        layer.cornerRadius  = 12
        layer.borderWidth   = 2
        layer.borderColor = UIColor.white.cgColor
        clipsToBounds       = true
        
        iconView.tintColor  = .white
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.textColor = .white
        nameLabel.font      = .boldSystemFont(ofSize: 14)
        nameLabel.textAlignment = .center
        
        countLabel.textColor = .lightGray
        countLabel.font      = .systemFont(ofSize: 12)
        countLabel.textAlignment = .center
        countLabel.numberOfLines = 1
        countLabel.adjustsFontSizeToFitWidth = true
        countLabel.minimumScaleFactor = 0.6
        countLabel.lineBreakMode = .byTruncatingTail
        
        let stack = UIStackView(arrangedSubviews: [iconView, nameLabel, countLabel])
        stack.axis         = .vertical
        stack.spacing      = 6
        stack.alignment    = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            
            iconView.heightAnchor.constraint(equalToConstant: 30),
            iconView.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(with s: SegmentSummary) {
        
        nameLabel.text  = s.nombre
        countLabel.text = "\(s.enlaces) enlaces"
        
        iconView.image      = UIImage(named: "network")
        iconView.tintColor  = .lightGray
        iconView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        iconView.widthAnchor.constraint(equalToConstant: 40).isActive  = true
        
        switch s.estado.lowercased() {
        case "ok":
            layer.borderColor = UIColor.systemGreen.cgColor
        case "error":
            layer.borderColor = UIColor.systemRed.cgColor
        default:
            layer.borderColor = UIColor.systemYellow.cgColor
        }
    }
    
    override var isSelected: Bool {
        didSet { alpha = isSelected ? 0.8 : 1.0 }
    }
    
}
