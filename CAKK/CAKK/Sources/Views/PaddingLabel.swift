//
//  PaddingLabel.swift
//  CAKK
//
//  Created by Mason Kim on 2023/08/07.
//

import UIKit

class PaddingLabel: UILabel {
  
  let topInset: CGFloat
  let leftInset: CGFloat
  let bottomInset: CGFloat
  let rightInset: CGFloat
  
  init(top: CGFloat = 0, left: CGFloat = 0,
       bottom: CGFloat = 0, right: CGFloat = 0) {
    self.topInset = top
    self.leftInset = left
    self.bottomInset = bottom
    self.rightInset = right
    super.init(frame: CGRect.zero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func drawText(in rect: CGRect) {
    let insets = UIEdgeInsets(top: topInset, left: leftInset,
                              bottom: bottomInset, right: rightInset)
    super.drawText(in: rect.inset(by: insets))
  }
  
  override var intrinsicContentSize: CGSize {
    let size = super.intrinsicContentSize
    return CGSize(width: size.width + leftInset + rightInset,
                  height: size.height + topInset + bottomInset)
  }
}
