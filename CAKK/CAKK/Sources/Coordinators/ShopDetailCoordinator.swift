//
//  ShopDetailCoordinator.swift
//  CAKK
//
//  Created by 이승기 on 2023/08/19.
//


import UIKit

final class ShopDetailCoordinator: Coordinator {
  
  // MARK: - Properties
  
  enum event: CoordinatorEvent { }
  
  var childCoordinators: [any Coordinator] = []
  var navigationController: UINavigationController
  
  let cakeShopID: Int
  let serviceType: NetworkServiceType
  let storage: RealmStorageProtocol
  
  
  // MARK: - Initializers
  
  init(navigationController: UINavigationController,
       cakeShopID: Int,
       serviceType: NetworkServiceType,
       storage: RealmStorageProtocol) {
    self.navigationController = navigationController
    self.cakeShopID = cakeShopID
    self.serviceType = serviceType
    self.storage = storage
  }
  
  
  // MARK: - Methods
  
  func start() {
    let networkService = NetworkService<CakeAPI>(type: serviceType, isLogEnabled: false)
    let viewModel = ShopDetailViewModel(cakeShopID: cakeShopID,
                                        service: networkService,
                                        realmStorage: storage)
    let vc = ShopDetailViewController(viewModel: viewModel)
    vc.isFullState = true
    vc.modalPresentationStyle = .fullScreen
    navigationController.viewControllers.last?.dismiss(animated: true)
    navigationController.present(vc, animated: true)
  }
  
  func eventOccurred(event: ShopDetailCoordinator.event) { }
}
