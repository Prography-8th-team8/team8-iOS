//
//  BookmarkCoordinator.swift
//  CAKK
//
//  Created by 이승기 on 2023/08/19.
//


import UIKit

final class BookmarkCoordinator: Coordinator {
  
  // MARK: - Properties
  
  enum event: CoordinatorEvent { }
  
  var childCoordinators: [any Coordinator] = []
  var navigationController: UINavigationController
  let tabBarController: UITabBarController
  let storage: RealmStorageProtocol
  
  
  // MARK: - Initializers
  
  init(navigationController: UINavigationController,
       tabBarController: UITabBarController,
       storage: RealmStorageProtocol) {
    self.navigationController = navigationController
    self.tabBarController = tabBarController
    self.storage = storage
  }
  
  
  // MARK: - Methods
  
  func start() {
    let viewModel = MyBookmarkViewModel(realmStorage: storage)
    let vc = MyBookmarkViewController(viewModel: viewModel)
    vc.tabBarItem = .init(title: "북마크", image: R.image.heart()!, tag: 2)
    
    if tabBarController.viewControllers == nil {
      tabBarController.viewControllers = [vc]
    } else {
      tabBarController.viewControllers?.append(vc)
    }
  }
  
  func eventOccurred(event: FeedCoordinator.event) { }
}
