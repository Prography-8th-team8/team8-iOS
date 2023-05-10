//
//  UIStackView+Seperator.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/10.
//

import UIKit

extension UIStackView {
  /// view의 frame 크기가 결정된 후 호출해야 하기에 `viewDidAppear` 에서 호출할 것!
  func addSeparators(color: UIColor, width: CGFloat = 1) {
    arrangedSubviews.enumerated().forEach { index, view in
      guard index < arrangedSubviews.count - 1 else { return }
      
      switch axis {
      case .vertical:
        view.addBorder(to: .bottom, color: color, width: width)
      case .horizontal:
        view.addBorder(to: .right, color: color, width: width)
      @unknown default:
        break
      }
    }
  }
}
