//
//  DIContainer.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/19.
//

import Foundation

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
  
  func makeMainViewController(districts: [District]) -> MainViewController {
    let viewModel = MainViewModel(districts: districts, service: networkService)
    return MainViewController(viewModel: viewModel)
  }
  
  func makeDistrictSelectionController() -> DistrictSelectionViewController {
    let viewModel = DistrictSelectionViewModel()
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
