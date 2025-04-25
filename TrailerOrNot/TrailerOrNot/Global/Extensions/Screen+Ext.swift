import UIKit

struct Screen {
    static var size: ScreenSize {
        let screenWidth = UIScreen.main.bounds.width
        switch screenWidth {
        case 0..<300:
            return .tiny
        case 300..<500:
            return .small
        case 500..<800:
            return .medium
        case 800..<1200:
            return .big
        default:
            return .large
        }
    }
}
