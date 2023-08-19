//
//  FeedCoordinator.swift
//  CAKK
//
//  Created by 이승기 on 2023/08/19.
//


import UIKit

final class FeedCoordinator: Coordinator {
  
  // MARK: - Properties
  
  var childCoordinators: [Coordinator] = []
  var navigationController: UINavigationController
  let serviceType: NetworkServiceType
  
  
  // MARK: - Initializers
  
  init(navigationController: UINavigationController,
       serviceType: NetworkServiceType) {
    self.navigationController = navigationController
    self.serviceType = serviceType
  }
  
  
  // MARK: - Methods
  
  func start() {
    let viewModel = FeedViewModel(service: NetworkService<CakeAPI>(type: serviceType, isLogEnabled: false))
    let vc = FeedViewController(viewModel: viewModel)
  }
}

