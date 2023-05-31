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
  
  func makeMainViewController() -> MainViewController {
    return MainViewController()
  }
  
  func makeOnboardingViewController() -> OnboardingViewController {
    let viewModel = OnboardingViewModel()
    return OnboardingViewController(viewModel: viewModel)
  }
  
  func makeShopDetailViewController(with cakeShop: CakeShop) -> ShopDetailViewController {
    let viewModel = ShopDetailViewModel(cakeShop: cakeShop, service: networkService)
    return ShopDetailViewController(viewModel: viewModel)
  }
  
  func makeCakeShopListViewController(with section: DistrictSection) -> CakeShopListViewController {
    let viewModel = CakeShopListViewModel(districtSection: section, service: networkService)
    return CakeShopListViewController(viewModel: viewModel)
  }
}
