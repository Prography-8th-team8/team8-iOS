//
//  UIFont+Pretendard.swift
//  CAKK
//
//  Created by 이승기 on 2023/04/25.
//

import UIKit

extension UIFont {
  
  enum PretendardWeight: String {
    case black      = "Black"
    case extraBold  = "ExtraBold"
    case bold       = "Bold"
    case semiBold   = "SemiBold"
    case medium     = "Medium"
    case regular    = "Regular"
    case light      = "Light"
    case extraLight = "ExtraLight"
    case thin       = "Thin"
  }
  
  static func pretendard(size: CGFloat = 14,
                         weight: PretendardWeight = .regular) -> UIFont {
    return UIFont(name: "Pretendard-\(weight.rawValue)", size: size)!
  }
}
