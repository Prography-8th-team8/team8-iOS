//
//  UIViewController+ShowAlert.swift
//  CAKK
//
//  Created by Mason Kim on 2023/06/04.
//

import UIKit

extension UIViewController {
  func showFailAlert(with title: String,
                     completion: (() -> Void)? = nil) {
    let alert = UIAlertController(title: title,
                                  message: nil, preferredStyle: .alert)
    let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
      completion?()
    }
    alert.addAction(confirmAction)
    
    present(alert, animated: true)
  }
  
  /// 사용자에게 Alert로 확인/취소를 물어보고 결과값을 completion으로 반환
  /// - Parameters:
  ///   - title: 물어볼 내용 title
  ///   - message: 본문 내용
  ///   - completion: 확인 시 true, 취소 시 false를 completion으로 반환
  func showAskAlert(title: String,
                    message: String? = nil,
                    completion: @escaping (Bool) -> Void) {
    let alert = UIAlertController(title: title,
                                  message: message, preferredStyle: .alert)
    
    let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
      completion(true)
    }
    let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
      completion(false)
    }
    alert.addAction(confirmAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true)
  }
}
