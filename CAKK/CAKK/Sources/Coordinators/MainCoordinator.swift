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
  var serviceType: NetworkServiceType
  
  
  // MARK: - Initializers
  
  init(navigationController: UINavigationController,
       serviceType: NetworkServiceType) {
    self.navigationController = navigationController
    self.serviceType = serviceType
  }
  
  
  // MARK: - Methods
  
  func start() {
    let networkService = NetworkService<CakeAPI>(type: serviceType, isLogEnabled: false)
    let realmStorage: RealmStorageProtocol = RealmStorage()
    let viewModel = MainViewModel(service: networkService, storage: realmStorage)
    let vc = MainViewController(viewModel: viewModel)
  }
}

