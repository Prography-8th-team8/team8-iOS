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
  let networkService: NetworkService<CakeAPI> = NetworkService(type: .server, isLogEnabled: false)
  let realmStorage: RealmStorageProtocol = RealmStorage()
  
  
  // MARK: - Initializers
  
  init(_ window: UIWindow,
       navigationController: UINavigationController) {
    self.window = window
    self.navigationController = navigationController
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
