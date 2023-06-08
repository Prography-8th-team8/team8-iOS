//
//  SceneDelegate.swift
//  CAKK
//
//  Created by CAKK on 2023/03/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  // MARK: - Constants
  
  enum Constants {
    static let splashFadeOutDuration = 0.2.f
  }
  
  
  // MARK: - Properties
  
  var window: UIWindow?
  
  
  // MARK: - LifeCycle
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    let window = UIWindow(windowScene: windowScene)
    
    let mainViewController = DIContainer.shared.makeMainViewController(districts: [])
    window.rootViewController = mainViewController
    window.makeKeyAndVisible()
    self.window = window
    
    startSplash(on: mainViewController)
  }
  
  
  // MARK: - Methods
  
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
}
