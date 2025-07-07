import UIKit

extension UIColor {
    convenience init(hex: String) {
        var c = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if c.hasPrefix("#") { c.removeFirst() }
        
        var rgb: UInt64 = 0
        Scanner(string: c).scanHexInt64(&rgb)
        
        self.init(
            red:   CGFloat((rgb >> 16) & 0xFF) / 255.0,
            green: CGFloat((rgb >>  8) & 0xFF) / 255.0,
            blue:  CGFloat( rgb        & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}
