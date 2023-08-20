//
//  FeedCoordinator.swift
//  CAKK
//
//  Created by 이승기 on 2023/08/19.
//


import UIKit

final class FeedCoordinator: Coordinator {
  
  // MARK: - Properties
  
  enum event: CoordinatorEvent {
    case showFeedDetail(_ feed: Feed)
  }
  
  var childCoordinators: [any Coordinator] = []
  var navigationController: UINavigationController
  let tabBarController: UITabBarController
  let serviceType: NetworkServiceType
  
  
  // MARK: - Initializers
  
  init(navigationController: UINavigationController,
       tabBarController: UITabBarController,
       serviceType: NetworkServiceType) {
    self.navigationController = navigationController
    self.tabBarController = tabBarController
    self.serviceType = serviceType
  }
  
  
  // MARK: - Methods
  
  func start() {
    let viewModel = FeedViewModel(service: NetworkService<CakeAPI>(type: serviceType, isLogEnabled: false))
    let vc = FeedViewController(viewModel: viewModel)
    vc.coordinator = self
    vc.tabBarItem = .init(title: "피드", image: R.image.magnifying_glass()!, tag: 1)
    
    if tabBarController.viewControllers == nil {
      tabBarController.viewControllers = [vc]
    } else {
      tabBarController.viewControllers?.append(vc)
    }
  }
  
  func eventOccurred(event: FeedCoordinator.event) {
    switch event {
    case .showFeedDetail(let feed):
      let feedDetailCoordinator = FeedDetailCoordinator(
        navigationController: navigationController,
        feed: feed,
        serviceType: serviceType)
      feedDetailCoordinator.start()
    }
  }
}
