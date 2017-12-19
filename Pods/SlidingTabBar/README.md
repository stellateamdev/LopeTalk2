# SlidingTabBar

[![CocoaPods](https://img.shields.io/cocoapods/p/SlidingTabBar.svg)](http://cocoapods.org/pods/SlidingTabBar)
[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Twitter](https://img.shields.io/badge/Twitter-@bardonadam-blue.svg?style=flat)](http://twitter.com/bardonadam)
[![Version](https://img.shields.io/cocoapods/v/SlidingTabBar.svg?style=flat)](http://cocoapods.org/pods/SlidingTabBar)
[![License](https://img.shields.io/cocoapods/l/SlidingTabBar.svg?style=flat)](http://cocoapods.org/pods/SlidingTabBar)


A custom TabBar view with sliding animation written in Swift. Inspired by this [dribble](https://dribbble.com/shots/2071319-GIF-of-the-Tapbar-Interactions).

Also, read how it was done on my blog - [part 1](http://blog.adambardon.com/how-to-create-custom-tab-bar-in-swift-part-1/?utm_source=github), [part 2](http://blog.adambardon.com/how-to-create-custom-tab-bar-in-swift-part-2/?utm_source=github).

![Animation](screenshot.gif)

## Requirements
- iOS 8.0+
- Xcode 7.2+
- Swift 2+

## Installation

SlidingTabBar is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SlidingTabBar"
```

## Usage

First create your _UITabBarViewController_ class and import SlidingTabBar:

```swift
import SlidingTabBar
```

Make it adopt _SlidingTabBarDataSource_, _SlidingTabBarDelegate_ and _UITabBarControllerDelegate_ protocols:

```swift
class YourViewController: UITabBarController, SlidingTabBarDataSource, SlidingTabBarDelegate, UITabBarControllerDelegate
```

In _viewDidLoad()_ set default _UITabBar_ as hidden, set `selectedIndex` as you need and set the delegate.

```swift
self.tabBar.hidden = true
self.selectedIndex = 1
self.delegate = self
```

Create class variables:  
`var tabBarView: SlidingTabBar!`  
`var fromIndex: Int!`  
`var toIndex: Int!`  

Now initialize `tabBarView` in _viewDidLoad()_:

```swift
// use default UITabBar's frame or whatever you want
// number of selectedTabBarItemColors has to match number of your tab bar items

tabBarView = SlidingTabBar(frame: self.tabBar.frame, initialTabBarItemIndex: self.selectedIndex)
tabBarView.tabBarBackgroundColor = UIColor.black()
tabBarView.tabBarItemTintColor = UIColor.gray()
tabBarView.selectedTabBarItemTintColor = UIColor.white()
tabBarView.selectedTabBarItemColors = [UIColor.red(), UIColor.green(), UIColor.blue()]
tabBarView.slideAnimationDuration = 0.6
tabBarView.datasource = self
tabBarView.delegate = self
tabBarView.setup()

self.view.addSubview(tabBarView)
```

And implement those delegate and datasource methods:

```swift
// MARK: - SlidingTabBarDataSource
    
func tabBarItemsInSlidingTabBar(tabBarView: SlidingTabBar) -> [UITabBarItem] {
    return tabBar.items!
}
    
// MARK: - SlidingTabBarDelegate
    
func didSelectViewController(tabBarView: SlidingTabBar, atIndex index: Int, from: Int) {
    self.fromIndex = from
    self.toIndex = index
    self.selectedIndex = index
}
    
// MARK: - UITabBarControllerDelegate
    
func tabBarController(tabBarController: UITabBarController, animationControllerForTransitionFromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    // use same duration as for tabBarView.slideAnimationDuration
    // you can choose direction in which view controllers should be changed:
    // - .Both(default),
    // - .Reverse,
    // - .Left,
    // - .Right 
    return SlidingTabAnimatedTransitioning(transitionDuration: 0.6, direction: .Both,
     fromIndex: self.fromIndex, toIndex: self.toIndex)
}
```

Finally set things up in the Storyboard:

1. Add native _UITabBarController_ to the storyboard, establish relationships with its view controllers.
2. Choose YourViewController as custom class for _UITabBarController_.
3. Set images for all tab bar items:

![Imgur](http://i.imgur.com/tjTKQrl.png)

If you're implementing 3d touch - Home Screen Quick Actions, add this to _AppDelegate_:

```swift
func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
	
    // whatever type you have
    if shortcutItem.type == UIApplicationShortcutItem.type { 
        let tabBarController = (window?.rootViewController as! YourViewController)
        tabBarController.selectedIndex = 1 // whatever view controller you need
        tabBarController.tabBarView.initialTabBarItemIndex = tabBarController.selectedIndex
        tabBarController.tabBarView.reloadTabBarView()
            
        completionHandler(true)
    }
        
    completionHandler(false)
}
```

Enjoy! :)

## Author

Adam Bardon, bardon.adam@gmail.com, [@bardonadam](http://twitter.com/bardonadam)

## License

SlidingTabBar is available under the MIT license. See the LICENSE file for more info.
