//
//  UIViewController+ShowPopUp.swift
//  CAKK
//
//  Created by Mason Kim on 2023/07/30.
//

import UIKit

extension UIViewController {
  func showPopUp(titleText: String,
                 descriptionText: String? = nil,
                 confirmAction: @escaping () -> Void,
                 cancelAction: (() -> Void)? = nil) {
    let popUpController = PopUpViewController(titleText: titleText,
                                              descriptionText: descriptionText,
                                              confirmAction: confirmAction,
                                              cancelAction: cancelAction)
    self.present(popUpController, animated: false)
  }
}
