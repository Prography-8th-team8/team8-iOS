//
//  MainCoordinator.swift
//  CAKK
//
//  Created by 이승기 on 2023/08/19.
//


import UIKit

final class MainCoordinator: Coordinator {
  
  // MARK: - Properties
  
  var childCoordinators: [Coordinator] = []
  var navigationController: UINavigationController
  var tabBarController: UITabBarController
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
    let networkService = NetworkService<CakeAPI>(type: serviceType, isLogEnabled: false)
    let realmStorage: RealmStorageProtocol = RealmStorage()
    let viewModel = MainViewModel(service: networkService, storage: realmStorage)
    let vc = MainViewController(viewModel: viewModel)
    vc.tabBarItem = .init(title: "홈", image: R.image.home()!, tag: 0)
    
    if tabBarController.viewControllers == nil {
      tabBarController.viewControllers = [vc]
    } else {
      tabBarController.viewControllers?.append(vc)
    }
  }
}
