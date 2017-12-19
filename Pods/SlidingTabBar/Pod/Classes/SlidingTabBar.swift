//
//  SlidingTabBar.swift
//  
//
//  Created by Adam Bardon on 29/02/16.
//  Copyright © 2016 Adam Bardon. All rights reserved.
//
//  This software is released under the MIT License.
//  http://opensource.org/licenses/mit-license.php


import UIKit

public protocol SlidingTabBarDataSource {
    func tabBarItemsInSlidingTabBar(tabBarView: SlidingTabBar) -> [UITabBarItem]
}

public protocol SlidingTabBarDelegate {
    func didSelectViewController(tabBarView: SlidingTabBar, atIndex index: Int, from: Int)
}

public class SlidingTabBar: UIView {
    
    public var datasource: SlidingTabBarDataSource!
    public var delegate: SlidingTabBarDelegate!
    
    public var initialTabBarItemIndex: Int!
    public var slideAnimationDuration: Double!
    
    public var tabBarBackgroundColor: UIColor?
    public var tabBarItemTintColor: UIColor!
    public var selectedTabBarItemTintColor: UIColor?
    public var selectedTabBarItemColors: [UIColor]?
    
    private var tabBarItems: [UITabBarItem]!
    private var slidingTabBarItems: [SlidingTabBarItem]!
    private var tabBarButtons: [UIButton]!
    
    private var slideMaskDelay: Double!
    private var selectedTabBarItemIndex: Int!
    
    private var tabBarItemWidth: CGFloat!
    private var leftMask: UIView!
    private var rightMask: UIView!
    
    public var safeArea:CGFloat?
    
    public init(frame: CGRect, initialTabBarItemIndex: Int = 0) {
        super.init(frame: frame)
        
        self.initialTabBarItemIndex = initialTabBarItemIndex
        selectedTabBarItemIndex = initialTabBarItemIndex
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reloadTabBarView() {
        self.subviews.forEach { $0.removeFromSuperview() }
        selectedTabBarItemIndex = initialTabBarItemIndex
        setup()
    }
    
    public func setup() {
        if(safeArea == nil){
            safeArea = 0.0
        }
        tabBarItems = datasource.tabBarItemsInSlidingTabBar(tabBarView: self)
        
        guard let _ = tabBarItems else {
            fatalError("SlidingTabBar: add items in tabBar")
        }
        
        guard let slideAnimationDuration = slideAnimationDuration else {
            fatalError("SlidingTabBar: provide value for slideDuration")
        }
        
        guard let _ = tabBarBackgroundColor else {
            fatalError("SlidingTabBar: provide color for tabBarBackgroundColor")
        }
        
        guard let _ = tabBarItemTintColor else {
            fatalError("SlidingTabBar: provide color for tabBarItemTintColor")
        }
        
        guard let _ = selectedTabBarItemTintColor else {
            fatalError("SlidingTabBar: provide color for selectedTabBarItemTintColor")
        }
        
        guard let selectedTabBarItemColors = selectedTabBarItemColors else {
            fatalError("SlidingTabBar: provide colors for selectedTabBarItemColors")
        }
        
        guard selectedTabBarItemColors.count == tabBarItems.count else {
            fatalError("SlidingTabBar: amount of selectedTabBarItemColors is not equal to amount of tab bar items")
        }
        
        slideMaskDelay = slideAnimationDuration / 2
        
        tabBarButtons = []
        slidingTabBarItems = []
        
        let containers = createTabBarItemContainers()
        
        createTabBarItemSelectionOverlay(containers: containers)
        createTabBarItemSelectionOverlayMask(containers: containers)
        createTabBarItems(containers: containers)
    }
    
    private func createTabBarItemSelectionOverlay(containers: [CGRect]) {
        
        for index in 0..<tabBarItems.count {
            let container = containers[index]
            
            let view = UIView(frame: container)
            
            let selectedItemOverlay = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
            selectedItemOverlay.backgroundColor = selectedTabBarItemColors![index]
            view.addSubview(selectedItemOverlay)
            
            self.addSubview(view)
        }
    }
    
    private func createTabBarItems(containers: [CGRect]) {
        
        var index = 0
        for item in tabBarItems {
            
            let container = containers[index]
            
            let slidingTabBarItem = SlidingTabBarItem(frame: container, tintColor: tabBarItemTintColor, item: item)
            
            self.addSubview(slidingTabBarItem)
            slidingTabBarItems.append(slidingTabBarItem)
           
            let button = UIButton(frame: CGRect(x: 0, y:0, width: container.width, height:self.frame.height))
            button.backgroundColor = UIColor.yellow
            button.addTarget(self, action: #selector(barItemTapped), for: UIControlEvents.touchUpInside)
            
            print("check button frame \(button.frame) \(self.frame)")
            
            slidingTabBarItem.addSubview(button)
            tabBarButtons.append(button)
            
            index += 1
        }
        
        self.slidingTabBarItems[initialTabBarItemIndex].iconView.tintColor = selectedTabBarItemTintColor
    }
    
    private func createTabBarItemSelectionOverlayMask(containers: [CGRect]) {
        
        tabBarItemWidth = self.frame.width / CGFloat(tabBarItems.count)
        let leftOverlaySlidingMultiplier = CGFloat(initialTabBarItemIndex) * tabBarItemWidth
        let rightOverlaySlidingMultiplier = CGFloat(initialTabBarItemIndex + 1) * tabBarItemWidth
        
        leftMask = UIView(frame: CGRect(x: 0, y: 0, width: leftOverlaySlidingMultiplier, height: self.frame.height))
        leftMask.backgroundColor = tabBarBackgroundColor
        rightMask = UIView(frame: CGRect(x: rightOverlaySlidingMultiplier, y: 0, width: tabBarItemWidth * CGFloat(tabBarItems.count - 1), height: self.frame.height))
        rightMask.backgroundColor = tabBarBackgroundColor
        
        self.addSubview(leftMask)
        self.addSubview(rightMask)
    }
    
    private func createTabBarItemContainers() -> [CGRect] {
        
        var containerArray = [CGRect]()
        
        for index in 0..<tabBarItems.count {
            let tabBarContainer = createTabBarContainer(index: index)
            containerArray.append(tabBarContainer)
        }
        
        return containerArray
    }
    
    private func createTabBarContainer(index: Int) -> CGRect {
        let tabBarContainerWidth = self.frame.width / CGFloat(tabBarItems.count)
        let tabBarContainerRect = CGRect(x: tabBarContainerWidth * CGFloat(index), y: -34, width: tabBarContainerWidth, height: self.frame.height) // minus 44 to fit for iphone x
        
        return tabBarContainerRect
    }
    
    private func animateTabBarSelection(from: Int, to: Int) {
        
        let overlaySlidingMultiplier = CGFloat(to - from) * tabBarItemWidth
        
        let leftMaskDelay: Double
        let rightMaskDelay: Double
        if overlaySlidingMultiplier > 0 {
            leftMaskDelay = slideMaskDelay
            rightMaskDelay = 0
        }
        else {
            leftMaskDelay = 0
            rightMaskDelay = slideMaskDelay
        }
        
        UIView.animate(withDuration: slideAnimationDuration - leftMaskDelay, delay: leftMaskDelay, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.leftMask.frame.size.width += overlaySlidingMultiplier
            }, completion: nil)
        
        UIView.animate(withDuration: slideAnimationDuration - rightMaskDelay, delay: rightMaskDelay, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.rightMask.frame.origin.x += overlaySlidingMultiplier
            self.rightMask.frame.size.width += -overlaySlidingMultiplier
            self.slidingTabBarItems[from].iconView.tintColor = self.tabBarItemTintColor
            self.slidingTabBarItems[to].iconView.tintColor = self.selectedTabBarItemTintColor
            }, completion: nil)
        
    }
    
    @objc public func barItemTapped(sender : UIButton) {
        print("enter button")
        let index = tabBarButtons.index(of: sender)!
        let from = selectedTabBarItemIndex
        
        animateTabBarSelection(from: from!, to: index)
        selectedTabBarItemIndex = index
        delegate.didSelectViewController(tabBarView: self, atIndex: index, from: from!)
    }

}
extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
}
