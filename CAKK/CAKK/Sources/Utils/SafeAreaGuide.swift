//
//  SafeAreaGuide.swift
//  CAKK
//
//  Created by Mason Kim on 2023/04/04.
//

import UIKit

enum SafeAreaGuide {
  static var top: CGFloat {
    let window = UIApplication.shared.windows.first!
    let topHeight = window.safeAreaInsets.top
    return topHeight
  }
}
