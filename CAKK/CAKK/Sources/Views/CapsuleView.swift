//
//  CapsuleView.swift
//  CAKK
//
//  Created by 이승기 on 2023/04/26.
//

import UIKit

class CapsuleView: UIView {
  
  override var frame: CGRect {
    didSet {
      if oldValue != frame {
        configureCornerRadius()
      }
    }
  }
  
  private func configureCornerRadius() {
    layer.cornerRadius = frame.height / 2
  }
}
