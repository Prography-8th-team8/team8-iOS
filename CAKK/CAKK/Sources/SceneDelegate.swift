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
    
    // 루트뷰를 메인뷰로 설정
    let viewModel = OnboardingViewModel()
    let onboardingViewController = OnboardingViewController(viewModel: viewModel)
    window.rootViewController = onboardingViewController
    self.window = window
    window.makeKeyAndVisible()
    
    // 스플래시 시작
    let splashViewController = SplashViewController()
    splashViewController.modalPresentationStyle = .overCurrentContext // splashViewController.view.alpha = 0 했을 시에 배경이 검정색이 아닌 투명으로 보여주기 위함
    onboardingViewController.present(splashViewController, animated: false)
    
    splashViewController.startSplash {
      UIView.animate(withDuration: Constants.splashFadeOutDuration) {
        splashViewController.view.alpha = 0
      } completion: { _ in
        splashViewController.dismiss(animated: true)
      }
    }
  }
}
