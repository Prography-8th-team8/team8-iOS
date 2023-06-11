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
  func showToast(with message: String, delay: TimeInterval = 1) {
    let horizontalPadding = 20.f
    let verticalPadding = 10.f
    
    let toastView = UIView().then {
      $0.backgroundColor = .black
      $0.layer.cornerRadius = 10
    }
    let toastLabel = UILabel().then {
      $0.text = message
      $0.textColor = .white
      $0.textAlignment = .center
      $0.numberOfLines = 0
      $0.font = .pretendard()
    }
    
    toastView.addSubview(toastLabel)
    toastLabel.snp.makeConstraints {
      $0.horizontalEdges.equalToSuperview().inset(horizontalPadding)
      $0.verticalEdges.equalToSuperview().inset(verticalPadding)
    }
    
    view.addSubview(toastView)
    toastView.snp.makeConstraints {
      $0.horizontalEdges.equalToSuperview().inset(horizontalPadding)
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
    }
    
    toastView.alpha = 0.0
    
    UIView.animate(withDuration: 0.5) {
      toastView.alpha = 1.0
    } completion: { _ in
      
      UIView.animate(withDuration: 0.5, delay: delay) {
        toastView.alpha = 0.0
      } completion: { _ in
        toastView.removeFromSuperview()
      }
    }
  }
}
