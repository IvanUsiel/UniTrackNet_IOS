import Foundation
import UIKit

struct UserProfile: Codable {
    let username: String
    let fullname: String
    let email: String
    let role: String
    var currentIP: String
    var lastLogin: Date
    var isFaceIDEnabled: Bool
    var avatarImageData: Data?
    var avatarImage: UIImage? {
        get {
            guard let data = avatarImageData else { return nil }
            return UIImage(data: data)
        }
        set {
            avatarImageData = newValue?.jpegData(compressionQuality: 0.8)
        }
    }
}
