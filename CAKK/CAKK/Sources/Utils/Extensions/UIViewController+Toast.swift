//
//  UIViewController+Toast.swift
//  CAKK
//
//  Created by Mason Kim on 2023/06/11.
//

import UIKit

import SnapKit
import Then

extension UIViewController {
  
  private enum ToastMetric {
    static let horizontalPadding = 24.f
    static let verticalPadding = 16.f
    static let bottomInset = 30.f
  }
  
  func showToast(with message: String, delay: TimeInterval = 1) {
    let toastView = UIView().then {
      $0.clipsToBounds = true
      $0.layer.cornerRadius = 12
      $0.isUserInteractionEnabled = false
      $0.alpha = 0
      $0.transform = .init(scaleX: 0.7, y: 0.7)
    }
    
    let blurEffect = UIBlurEffect(style: .dark)
    let blurView = UIVisualEffectView(effect: blurEffect)
    toastView.addSubview(blurView)
    blurView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    let toastLabel = UILabel().then {
      $0.text = message
      $0.textColor = .white
      $0.textAlignment = .center
      $0.numberOfLines = 3
      $0.font = .pretendard(size: 16)
    }
    
    toastView.addSubview(toastLabel)
    toastLabel.snp.makeConstraints {
      $0.horizontalEdges.equalToSuperview().inset(ToastMetric.horizontalPadding)
      $0.verticalEdges.equalToSuperview().inset(ToastMetric.verticalPadding)
    }
    
    view.addSubview(toastView)
    toastView.snp.makeConstraints {
      $0.horizontalEdges.equalToSuperview().inset(ToastMetric.horizontalPadding)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(ToastMetric.bottomInset)
    }
    
    UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8) {
      toastView.alpha = 1.0
      toastView.transform = .init(scaleX: 1, y: 1)
    } completion: { _ in
      
      UIView.animate(withDuration: 0.25, delay: delay) {
        toastView.alpha = 0.0
      } completion: { _ in
        toastView.removeFromSuperview()
      }
    }
  }
}
