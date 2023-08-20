//
//  TabBarController.swift
//  CAKK
//
//  Created by 이승기 on 2023/07/26.
//

import UIKit

final class TabBarController: UITabBarController {
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTabBar()
  }
  
  // MARK: - Setup
  
  private func setupTabBar() {
    setupTabBarAppearance()
    setupToastManager()
  }
  
  private func setupTabBarAppearance() {
    UITabBar.appearance().barTintColor = R.color.gray_80()
    UITabBar.appearance().tintColor = R.color.pink_100()
    UITabBar.appearance().isTranslucent = true
    
    if #available(iOS 15.0, *) {
      let appearance = UITabBarAppearance()
      appearance.configureWithOpaqueBackground()
      appearance.backgroundColor = R.color.white()
      appearance.backgroundEffect = .init(style: .regular)
      UITabBar.appearance().standardAppearance = appearance
      UITabBar.appearance().scrollEdgeAppearance = appearance
    }
  }
  
  private func setupToastManager() {
    ToastManager.shared.setTargetViewController(self)
  }
}
