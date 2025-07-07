import UIKit

class LoadingOverlay {
    
    static let shared = LoadingOverlay()
    private var overlayView: UIView = UIView()
    private var activityIndicator = UIActivityIndicatorView(style: .large)
    
    private init() {
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor)
        ])
    }
    
    func show(over parent: UIView) {
        overlayView.frame = parent.bounds
        parent.addSubview(overlayView)
        activityIndicator.startAnimating()
    }
    
    func hide() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
}
