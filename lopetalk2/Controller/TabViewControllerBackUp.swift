

import UIKit
import SlidingTabBar

class TabViewControllerBackUp: UITabBarController, SlidingTabBarDataSource, SlidingTabBarDelegate, UITabBarControllerDelegate {
    
    var tabBarView: SlidingTabBar!
    var fromIndex: Int!
    var toIndex: Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.tabBar.isHidden = true
        
        let tabBarFrame = self.tabBar.frame
        self.selectedIndex = 0
        
        tabBarView = SlidingTabBar(frame: tabBarFrame, initialTabBarItemIndex: 0)
        tabBarView.tabBarBackgroundColor = UIColor.blue
        tabBarView.tabBarItemTintColor = UIColor.gray
        tabBarView.selectedTabBarItemTintColor = UIColor.lopeColor()
        tabBarView.selectedTabBarItemColors = [UIColor.black,UIColor.white,UIColor.blue]
        tabBarView.slideAnimationDuration = 0.1
        tabBarView.datasource = self
        tabBarView.delegate = self
        tabBarView.setup()
        
        // UITabBarControllerDelegate, for animationControllerForTransitionFromViewController
        self.delegate = self
        
        self.view.addSubview(tabBarView)
    }
    
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
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return SlidingTabAnimatedTransitioning(transitionDuration: 0.1, direction: .Both, fromIndex: self.fromIndex, toIndex: self.toIndex)
    }
}

