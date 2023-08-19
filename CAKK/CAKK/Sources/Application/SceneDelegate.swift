//
//  SceneDelegate.swift
//  CAKK
//
//  Created by CAKK on 2023/03/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  
  // MARK: - Properties
  
  var window: UIWindow?
  
  
  // MARK: - LifeCycle
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    let window = UIWindow(windowScene: windowScene)
    let appCoordinator = AppCoordinator(window)
    self.window = window
    
    appCoordinator.start()
  }
}
