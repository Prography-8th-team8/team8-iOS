//
//  DIContainer.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/19.
//

import UIKit

final class DIContainer {
  
  // MARK: - Singleton
  
  static let shared = DIContainer()
  private init() { }
  
  // MARK: - Properties
  
  private let networkService: NetworkService<CakeAPI> = NetworkService(type: .server, isLogEnabled: false)
  private let realmStorage: RealmStorageProtocol = RealmStorage()
  
  // MARK: - DI Factory Methods
  
  func makeSplashViewController() -> SplashViewController {
    return SplashViewController()
  }
  
  func makeMainViewController(districts: [District]) -> UINavigationController {
    let viewModel = MainViewModel(districts: districts, service: networkService)
    let controller = MainViewController(viewModel: viewModel)
    return UINavigationController(rootViewController: controller)
  }
  
  func makeDistrictSelectionController() -> DistrictSelectionViewController {
    let viewModel = DistrictSelectionViewModel(service: networkService)
    return DistrictSelectionViewController(viewModel: viewModel)
  }
  
  func makeShopDetailViewController(with cakeShop: CakeShop) -> ShopDetailViewController {
    let viewModel = ShopDetailViewModel(cakeShop: cakeShop,
                                        service: networkService,
                                        realmStorage: realmStorage)
    return ShopDetailViewController(viewModel: viewModel)
  }
  
  func makeCakeShopListViewController(mainViewModel: MainViewModel) -> CakeShopListViewController {
    return CakeShopListViewController(viewModel: mainViewModel)
  }
  
  func makeFilterViewController(viewModel: FilterViewModel) -> FilterViewController {
    let viewModel = FilterViewModel()
    return FilterViewController(viewModel: viewModel)
  }
}
