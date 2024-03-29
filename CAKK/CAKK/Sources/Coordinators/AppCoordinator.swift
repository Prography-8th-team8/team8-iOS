//
//  AppCoordinator.swift
//  CAKK
//
//  Created by 이승기 on 2023/08/19.
//

import UIKit

final class AppCoordinator: Coordinator {
  
  // MARK: - Constants
  
  enum Constants {
    static let splashFadeOutDuration = 0.2.f
  }
  
  
  // MARK: - Properties
  
  enum event: CoordinatorEvent { }
  
  var childCoordinators: [any Coordinator] = []
  var navigationController: UINavigationController
  let window: UIWindow
  let serviceType: NetworkServiceType = .server
  
  
  // MARK: - Initializers
  
  init(_ window: UIWindow) {
    self.window = window
    
    // Initialize navigation controller
    let navigationController = UINavigationController()
    navigationController.setNavigationBarHidden(true, animated: false)
    self.navigationController = navigationController
  }
  
  
  // MARK: - Methods
  
  func start() {
    let tabBarCoordinator = TabCoordinator(window, navigationController: navigationController, serviceType: serviceType)
    childCoordinators.append(tabBarCoordinator)
    tabBarCoordinator.start()
    startSplash(on: navigationController)
  }
  
  private func startSplash(on superViewController: UIViewController) {
    let splashViewController = SplashViewController()
    splashViewController.modalPresentationStyle = .overFullScreen
    superViewController.present(splashViewController, animated: false)
    splashViewController.startSplash {
      UIView.animate(withDuration: Constants.splashFadeOutDuration) {
        splashViewController.view.alpha = 0
      } completion: { _ in
        splashViewController.dismiss(animated: false)
      }
    }
  }
  
  func eventOccurred(event: AppCoordinator.event) { }
}
