//
//  UIStackView+Seperator.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/10.
//

import UIKit

extension UIStackView {
  func addSeparators(color: UIColor, width: CGFloat) {
    arrangedSubviews.enumerated().forEach { index, view in
      guard index < arrangedSubviews.count - 1 else { return }
      
      switch axis {
      case .vertical:
        view.addBorder(edge: .bottom, color: color, width: width)
      case .horizontal:
        view.addBorder(edge: .right, color: color, width: width)
      @unknown default:
        break
      }
    }
  }
}
