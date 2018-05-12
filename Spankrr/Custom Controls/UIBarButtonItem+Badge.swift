import UIKit

private var handle: UInt8 = 0;

extension UIBarButtonItem {
    private var badgeLabel: UILabel? {
        if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
            return b as? UILabel
        } else {
            return nil
        }
    }
    
    func setBadge(number: Int, offset: CGPoint = CGPoint.zero) {
        if let badgeLabel = badgeLabel {
            badgeLabel.text = "\(number)"
        }else{
            guard let view = self.value(forKey: "view") as? UIView else { return }
            
            let badgeLabel = UILabel()
            badgeLabel.frame.size = CGSize.init(width: 18, height: 18)
            badgeLabel.center = CGPoint.init(x: view.frame.width + offset.x, y: offset.y)
            badgeLabel.text = "\(number)"
            badgeLabel.font = UIFont.init(name: "helvetica", size: 14)
            badgeLabel.makeCircularView()
            badgeLabel.textColor = .white
            badgeLabel.backgroundColor = .red
            badgeLabel.textAlignment = .center
            view.addSubview(badgeLabel)
            
            objc_setAssociatedObject(self, &handle, badgeLabel, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func updateBadge(number: Int) {
        if let badgeLabel = badgeLabel {
            badgeLabel.text = "\(number)"
        }
    }
    
    func removeBadge() {
        if let badgeLabel = badgeLabel {
            badgeLabel.removeFromSuperview()
        }
    }
}
