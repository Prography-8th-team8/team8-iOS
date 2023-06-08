//
//  CapsuleView.swift
//  CAKK
//
//  Created by 이승기 on 2023/04/26.
//

import UIKit

class CapsuleView: UIView {
  
  var oldFrame: CGRect = .zero
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if oldFrame != frame {
      configureCornerRadius()
      oldFrame = frame
    }
  }
  
  private func configureCornerRadius() {
    layer.cornerRadius = frame.height / 2
  }
}
