import UIKit

class SegmentCell: UITableViewCell {
    
    private let statusIndicator = UIView()
    private let container = UIStackView()
    
    private let segmentoLabel  = UILabel()
    private let origenHostLabel = UILabel()
    private let origenIPLabel   = UILabel()
    private let destinoHostLabel = UILabel()
    private let destinoIPLabel   = UILabel()
    private let protoLabel      = UILabel()
    private let estadoLabel     = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:)") }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        statusIndicator.translatesAutoresizingMaskIntoConstraints = false
        statusIndicator.layer.cornerRadius = 4
        contentView.addSubview(statusIndicator)
        NSLayoutConstraint.activate([
            statusIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            statusIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            statusIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            statusIndicator.widthAnchor.constraint(equalToConstant: 6)
        ])
        
        container.axis = .vertical
        container.spacing = 6
        container.alignment = .fill
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(white: 0.1, alpha: 0.9)
        container.layer.cornerRadius = 10
        container.isLayoutMarginsRelativeArrangement = true
        container.layoutMargins = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        
        contentView.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: statusIndicator.trailingAnchor, constant: 8),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        [segmentoLabel, origenHostLabel, origenIPLabel,
         destinoHostLabel, destinoIPLabel, protoLabel, estadoLabel].forEach {
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 13, weight: .medium)
        }
        
        estadoLabel.font = .boldSystemFont(ofSize: 13)
        estadoLabel.textColor = .systemRed
        
        container.addArrangedSubview(segmentoLabel)
        
        let origenStack = horizontalRow(left: origenHostLabel, right: destinoHostLabel)
        let ipStack     = horizontalRow(left: origenIPLabel, right: destinoIPLabel)
        let protoStack  = horizontalRow(left: protoLabel, right: UIView()) 
        
        container.addArrangedSubview(origenStack)
        container.addArrangedSubview(ipStack)
        container.addArrangedSubview(protoStack)
        container.addArrangedSubview(estadoLabel)
    }
    
    private func horizontalRow(left: UIView, right: UIView) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [left, right])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }
    
    func configure(with seg: SegmentUiModel) {
        
        segmentoLabel.text   = "Segmento: \(seg.segmento)"
        origenHostLabel.text = "Punta A: \(seg.origen)"
        origenIPLabel.text   = "IP: \(seg.origenIP)"
        destinoHostLabel.text = "Punta B: \(seg.destino)"
        destinoIPLabel.text   = "IP: \(seg.destinoIP)"
        protoLabel.text      = "Protocolo: \(seg.tipo.rawValue.uppercased())"
        
        let isOK = seg.estado.lowercased() == "ok"
        estadoLabel.text      = isOK ? "✅ OK" : "⚠️ ERROR"
        estadoLabel.textColor = isOK ? .unitrackGreen : .systemRed
        statusIndicator.backgroundColor = isOK ? .unitrackGreen : .systemRed
    }
}
