//
//  TabCoordinator.swift
//  CAKK
//
//  Created by 이승기 on 2023/08/19.
//


import UIKit

final class TabCoordinator: Coordinator {
  
  // MARK: - Properties
  
  var childCoordinators: [Coordinator] = []
  var navigationController: UINavigationController
  var tabBarController: UITabBarController?
  let window: UIWindow
  let serviceType: NetworkServiceType
  
  
  // MARK: - Initializers
  
  init(_ window: UIWindow,
       navigationController: UINavigationController,
       serviceType: NetworkServiceType) {
    self.window = window
    self.navigationController = navigationController
    self.serviceType = serviceType
  }
  
  
  // MARK: - Methods
  
  func start() {
    let tabBarController = TabBarController()
    
    navigationController.pushViewController(tabBarController, animated: false)
    
    window.rootViewController = navigationController
    window.makeKeyAndVisible()
    
    self.tabBarController = tabBarController
  }
}
