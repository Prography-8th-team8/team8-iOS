//
//  UIStackView+Seperator.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/10.
//

import UIKit

extension UIStackView {
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
