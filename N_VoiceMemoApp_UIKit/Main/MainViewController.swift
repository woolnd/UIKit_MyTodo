//
//  MainViewController.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/2/25.
//

import UIKit

class MainViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setValue(CustomTabBar(), forKey: "tabBar") // 핵심 코드
        self.selectedIndex = 0
        setupStyle()
    }
    
    func setupStyle() {
        UITabBar.clearShadow()
        tabBar.layer.applyShadow(color: .gray, alpha: 0.3, x: 0, y: 0, blur: 12)
    }
}

class CustomTabBar: UITabBar {
    // 원하는 높이 지정
    private let customHeight: CGFloat = 90

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = customHeight
        return sizeThatFits
    }
}
