//
//  ToastManager.swift
//  CAKK
//
//  Created by 이승기 on 2023/08/15.
//

import ToastPiston

final class ToastManager {
  
  // MARK: - Constants
  
  static let shared = ToastManager()
  
  
  // MARK: - Properties
  
  private var targetViewController: UIViewController?
  
  
  // MARK: - Initializers
  
  private init() { }
  
  
  // MARK: - Public
  
  public func setTargetViewController(_ vc: UIViewController) {
    targetViewController = vc
  }
  
  public func showToast(message: String) {
    guard let targetViewController else { return }
    targetViewController.showPistonToast(title: message)
  }
}
