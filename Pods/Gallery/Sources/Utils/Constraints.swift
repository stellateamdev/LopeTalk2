import UIKit

extension UIView {
 
  @discardableResult func g_pin(on type1: NSLayoutAttribute,
             view: UIView? = nil, on type2: NSLayoutAttribute? = nil,
             constant: CGFloat = 0,
             priority: Float? = nil) -> NSLayoutConstraint? {
    guard let view = view ?? superview else {
      return nil
    }

    translatesAutoresizingMaskIntoConstraints = false
    let type2 = type2 ?? type1
    let constraint = NSLayoutConstraint(item: self, attribute: type1,
                                        relatedBy: .equal,
                                        toItem: view, attribute: type2,
                                        multiplier: 1, constant:constant)
    if let priority = priority {
        constraint.priority = UILayoutPriority(rawValue: priority)
    }

    constraint.isActive = true

    return constraint
  }
    
    @discardableResult func g_pinPageHeight(on type1: NSLayoutAttribute,
                                       view: UIView? = nil, on type2: NSLayoutAttribute? = nil,
                                       constant: CGFloat = 0,
                                       priority: Float? = nil) -> NSLayoutConstraint? {
        guard let view = view ?? superview else {
            return nil
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        let type2 = type2 ?? type1
        let constraint = NSLayoutConstraint(item: self, attribute: type1,
                                            relatedBy: .equal,
                                            toItem: view, attribute: type2,
                                            multiplier: 1, constant:0 - (UIDevice.iPhoneX ? 30:0))
        if let priority = priority {
            constraint.priority = UILayoutPriority(rawValue: priority)
        }
        
        constraint.isActive = true
        
        return constraint
    }
    @discardableResult func g_pinFlash(on type1: NSLayoutAttribute,
                                  view: UIView? = nil, on type2: NSLayoutAttribute? = nil,
                                  constant: CGFloat = 0,
                                  priority: Float? = nil) -> NSLayoutConstraint? {
        guard let view = view ?? superview else {
            return nil
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        let type2 = type2 ?? type1
        let constraint = NSLayoutConstraint(item: self, attribute: type1,
                                            relatedBy: .equal,
                                            toItem: view, attribute: type2,
                                            multiplier: 1, constant:0)
        if let priority = priority {
            constraint.priority = UILayoutPriority(rawValue: priority)
        }
        
        constraint.isActive = true
        
        return constraint
    }
    @discardableResult func g_pinOnTop(on type1: NSLayoutAttribute,
                                       view: UIView? = nil, on type2: NSLayoutAttribute? = nil,
                                       constant: CGFloat = 0,
                                       priority: Float? = nil) -> NSLayoutConstraint? {
        guard let view = view ?? superview else {
            return nil
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        let type2 = type2 ?? type1
        let constraint = NSLayoutConstraint(item: self, attribute: type1,
                                            relatedBy: .equal,
                                            toItem: view, attribute: type2,
                                            multiplier: 1, constant:0 + (UIDevice.iPhoneX ? 24:0))
        if let priority = priority {
            constraint.priority = UILayoutPriority(rawValue: priority)
        }
        
        constraint.isActive = true
        
        return constraint
    }
    @discardableResult func g_pinClose(on type1: NSLayoutAttribute,
                                       view: UIView? = nil, on type2: NSLayoutAttribute? = nil,
                                       constant: CGFloat = 0,
                                       priority: Float? = nil) -> NSLayoutConstraint? {
        guard let view = view ?? superview else {
            return nil
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        let type2 = type2 ?? type1
        let constraint = NSLayoutConstraint(item: self, attribute: type1,
                                            relatedBy: .equal,
                                            toItem: view, attribute: type2,
                                            multiplier: 1, constant:0 + (UIDevice.iPhoneX ? 24:0))
        if let priority = priority {
            constraint.priority = UILayoutPriority(rawValue: priority)
        }
        
        constraint.isActive = true
        
        return constraint
    }
    @discardableResult func g_pinCloseGalleryTop(on type1: NSLayoutAttribute,
                                                 view: UIView? = nil, on type2: NSLayoutAttribute? = nil,
                                                 constant: CGFloat = 0,
                                                 priority: Float? = nil) -> NSLayoutConstraint? {
        guard let view = view ?? superview else {
            return nil
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        let type2 = type2 ?? type1
        let constraint = NSLayoutConstraint(item: self, attribute: type1,
                                            relatedBy: .equal,
                                            toItem: view, attribute: type2,
                                            multiplier: 1, constant:(UIDevice.iPhoneX ? 7:-13))
        if let priority = priority {
            constraint.priority = UILayoutPriority(rawValue: priority)
        }
        
        constraint.isActive = true
        
        return constraint
    }
    @discardableResult func g_pinCloseGallery(on type1: NSLayoutAttribute,
                                       view: UIView? = nil, on type2: NSLayoutAttribute? = nil,
                                       constant: CGFloat = 0,
                                       priority: Float? = nil) -> NSLayoutConstraint? {
        guard let view = view ?? superview else {
            return nil
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        let type2 = type2 ?? type1
        let constraint = NSLayoutConstraint(item: self, attribute: type1,
                                            relatedBy: .equal,
                                            toItem: view, attribute: type2,
                                            multiplier: 1, constant:0 + (UIDevice.iPhoneX ? 14:0))
        if let priority = priority {
            constraint.priority = UILayoutPriority(rawValue: priority)
        }
        
        constraint.isActive = true
        
        return constraint
    }
    @discardableResult func g_pinPageButtom(on type1: NSLayoutAttribute,
                                              view: UIView? = nil, on type2: NSLayoutAttribute? = nil,
                                              constant: CGFloat = 0,
                                              priority: Float? = nil) -> NSLayoutConstraint? {
        guard let view = view ?? superview else {
            return nil
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        let type2 = type2 ?? type1
        let constraint = NSLayoutConstraint(item: self, attribute: type1,
                                            relatedBy: .equal,
                                            toItem: view, attribute: type2,
                                            multiplier: 1, constant:0 - (UIDevice.iPhoneX ? 34:0))
        if let priority = priority {
            constraint.priority = UILayoutPriority(rawValue: priority)
        }
        
        constraint.isActive = true
        
        return constraint
    }
    @discardableResult func g_pinSwitch(on type1: NSLayoutAttribute,
                                       view: UIView? = nil, on type2: NSLayoutAttribute? = nil,
                                       constant: CGFloat = 0,
                                       priority: Float? = nil) -> NSLayoutConstraint? {
        guard let view = view ?? superview else {
            return nil
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        let type2 = type2 ?? type1
        let constraint = NSLayoutConstraint(item: self, attribute: type1,
                                            relatedBy: .equal,
                                            toItem: view, attribute: type2,
                                            multiplier: 1, constant:0 + (UIDevice.iPhoneX ? 20:0))
        if let priority = priority {
            constraint.priority = UILayoutPriority(rawValue: priority)
        }
        
        constraint.isActive = true
        
        return constraint
    }

  func g_pinEdges(view: UIView? = nil) {
    g_pin(on: .top, view: view)
    g_pin(on: .bottom, view: view)
    g_pin(on: .left, view: view)
    g_pin(on: .right, view: view)
  }

  func g_pin(size: CGSize) {
    g_pin(width: size.width)
    g_pin(height: size.height)
  }

  func g_pin(width: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width))
  }

  func g_pin(height: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
  }
  
  func g_pin(greaterThanHeight height: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
  }

  func g_pinHorizontally(view: UIView? = nil, padding: CGFloat) {
    g_pin(on: .left, view: view, constant: padding)
    g_pin(on: .right, view: view, constant: -padding)
  }

    func g_pinUpwardCustom(view: UIView? = nil) {
        g_pinOnTop(on: .top, view: view)
        g_pin(on: .left, view: view)
        g_pin(on: .right, view: view)
    }
  func g_pinUpward(view: UIView? = nil) {
    g_pin(on: .top, view: view)
    g_pin(on: .left, view: view)
    g_pin(on: .right, view: view)
  }
    func g_pinDownwardCustom(view: UIView? = nil) {
        g_pinPageButtom(on: .bottom, view: view)
        g_pin(on: .left, view: view)
        g_pin(on: .right, view: view)
    }
  func g_pinDownward(view: UIView? = nil) {
    g_pin(on: .bottom, view: view)
    g_pin(on: .left, view: view)
    g_pin(on: .right, view: view)
  }

  func g_pinCenter(view: UIView? = nil) {
    g_pin(on: .centerX, view: view)
    g_pin(on: .centerY, view: view)
  }
}
extension UIDevice {
    class var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
}

