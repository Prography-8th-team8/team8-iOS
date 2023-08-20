//
//  TabCoordinator.swift
//  CAKK
//
//  Created by 이승기 on 2023/08/19.
//


import UIKit

final class TabCoordinator: Coordinator {
  
  // MARK: - Properties
  
  enum event: CoordinatorEvent {
    
  }
  
  var childCoordinators: [any Coordinator] = []
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
    tabBarController.navigationController?.setNavigationBarHidden(true, animated: false)
    self.tabBarController = tabBarController
    
    navigationController.pushViewController(tabBarController, animated: false)
    window.rootViewController = navigationController
    window.makeKeyAndVisible()
    
    // Main coordinator
    let mainCoordinator = MainCoordinator(
      navigationController: navigationController,
      tabBarController: tabBarController,
      serviceType: serviceType)
    childCoordinators.append(mainCoordinator)
    mainCoordinator.start()
    
    // Feed coordinator
    let feedCoordinator = FeedCoordinator(
      navigationController: navigationController,
      tabBarController: tabBarController,
      serviceType: serviceType)
    childCoordinators.append(feedCoordinator)
    feedCoordinator.start()
    
    // Bookmark coordinator
    let bookmarkCoordinator = BookmarkCoordinator(
      navigationController: navigationController,
      tabBarController: tabBarController,
      serviceType: serviceType,
      storage: RealmStorage())
    childCoordinators.append(bookmarkCoordinator)
    bookmarkCoordinator.start()
  }
  
  func eventOccurred(event: TabCoordinator.event) { }
}
