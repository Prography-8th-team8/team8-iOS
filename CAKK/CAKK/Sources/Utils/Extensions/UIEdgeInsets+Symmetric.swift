//
//  UIEdgeInsets+Symmetric.swift
//  CAKK
//
//  Created by 이승기 on 2023/07/21.
//

import UIKit

extension UIEdgeInsets {
  init(vertical: CGFloat, horizontal: CGFloat) {
    self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
  }
}
