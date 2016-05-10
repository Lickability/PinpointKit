import UIKit

/// Represents a editing tool.
enum Tool: Int {
    case Arrow
    case Box
    case Text
    case Blur
    
    var name: String {
        switch self {
        case .Arrow:
            return "Arrow Tool"
        case .Box:
            return "Box Tool"
        case .Text:
            return "Text Tool"
        case .Blur:
            return "Blur Tool"
        }
    }
    
    var image: UIImage {
        let bundle = NSBundle.pinpointKitBundle()
        
        func loadImage() -> UIImage? {
            switch self {
            case .Arrow:
                return UIImage(named: "ArrowIcon", inBundle: bundle, compatibleWithTraitCollection: nil)
            case .Box:
                return UIImage(named: "BoxIcon", inBundle: bundle, compatibleWithTraitCollection: nil)
            case .Text:
                return UIImage()
            case .Blur:
                return UIImage(named: "BlurIcon", inBundle: bundle, compatibleWithTraitCollection: nil)
            }
        }
        
        return loadImage() ?? UIImage()
    }
    
    var segmentedControlItem: AnyObject {
        switch self {
        case .Arrow, .Box, .Blur:
            let image = self.image
            image.accessibilityLabel = self.name
            return image
        case .Text:
            return NSLocalizedString("Aa", comment: "The text tool’s button label.")
        }
    }
}

