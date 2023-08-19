//
//  BookmarkCoordinator.swift
//  CAKK
//
//  Created by 이승기 on 2023/08/19.
//


import UIKit

final class BookmarkCoordinator: Coordinator {
  
  // MARK: - Properties
  
  enum event: CoordinatorEvent {
    case showShopDetail(bookmark: Bookmark)
  }
  
  var childCoordinators: [any Coordinator] = []
  var navigationController: UINavigationController
  let tabBarController: UITabBarController
  let serviceType: NetworkServiceType
  let storage: RealmStorageProtocol
  
  
  // MARK: - Initializers
  
  init(navigationController: UINavigationController,
       tabBarController: UITabBarController,
       serviceType: NetworkServiceType,
       storage: RealmStorageProtocol) {
    self.navigationController = navigationController
    self.tabBarController = tabBarController
    self.serviceType = serviceType
    self.storage = storage
  }
  
  
  // MARK: - Methods
  
  func start() {
    let viewModel = MyBookmarkViewModel(realmStorage: storage)
    let vc = MyBookmarkViewController(viewModel: viewModel)
    vc.coordinator = self
    vc.tabBarItem = .init(title: "북마크", image: R.image.heart()!, tag: 2)
    
    if tabBarController.viewControllers == nil {
      tabBarController.viewControllers = [vc]
    } else {
      tabBarController.viewControllers?.append(vc)
    }
  }
  
  func eventOccurred(event: BookmarkCoordinator.event) {
    switch event {
    case .showShopDetail(let bookmark):
      let shopDetailCoordinator = ShopDetailCoordinator(
        navigationController: navigationController,
        cakeShopID: bookmark.id,
        serviceType: serviceType,
        storage: storage)
      shopDetailCoordinator.start()
    }
  }
}
