//
//  UIColor+Hex.swift
//  CAKK
//
//  Created by 이승기 on 2023/05/05.
//

import UIKit

extension UIColor {
  convenience init(hex: Int) {
    self.init(
      red: (hex >> 16) & 0xFF,
      green: (hex >> 8) & 0xFF,
      blue: hex & 0xFF
    )
  }
}
