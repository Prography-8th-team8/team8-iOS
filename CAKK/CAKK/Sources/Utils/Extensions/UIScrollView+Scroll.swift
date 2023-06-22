//
//  UIScrollView+Scroll.swift
//  CAKK
//
//  Created by Mason Kim on 2023/04/12.
//

import UIKit

extension UIScrollView {
  func scrollToTop(animated: Bool = true) {
    let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
    setContentOffset(desiredOffset, animated: animated)
  }
}
