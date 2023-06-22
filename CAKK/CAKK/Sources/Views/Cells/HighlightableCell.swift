//
//  HighlightableCell.swift
//  CAKK
//
//  Created by 이승기 on 2023/05/13.
//

import UIKit

class HighlightableCell: UICollectionViewCell {
  
  // MARK: - Constants
  
  enum Constant {
    static let highlightDuration = 0.15.f
    static let unhighlightDuration = 0.2.f
  }
  
  enum Metric {
    static let highlightScale = 0.95.f
    static let unhighlightScale = 1.f
  }
  
  
  // MARK: - LifeCycles
  
  override var isHighlighted: Bool {
    didSet {
      if isHighlighted {
        highlightCell()
      } else {
        unhighlightCell()
      }
    }
  }

  
  // MARK: - Methods
  
  private func highlightCell() {
    UIView.animate(withDuration: Constant.highlightDuration,
                   delay: 0,
                   options: [.curveEaseInOut]) {
      self.transform = .init(scaleX: Metric.highlightScale, y: Metric.highlightScale)
    }
  }
  
  private func unhighlightCell() {
    UIView.animate(withDuration: Constant.unhighlightDuration,
                   delay: 0,
                   options: [.curveEaseInOut]) {
      self.transform = .init(scaleX: Metric.unhighlightScale, y: Metric.unhighlightScale)
    }
  }
}
