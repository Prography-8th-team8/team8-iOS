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
  
  private let networkService: NetworkService<CakeAPI> = NetworkService(type: .stub)
  
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
    let viewModel = ShopDetailViewModel(cakeShop: cakeShop, service: networkService)
    return ShopDetailViewController(viewModel: viewModel)
  }
  
  func makeCakeShopListViewController(initialCakeShops: [CakeShop]) -> CakeShopListViewController {
    let viewModel = CakeShopListViewModel(initialCakeShops: initialCakeShops, service: networkService)
    return CakeShopListViewController(viewModel: viewModel)
  }
}
