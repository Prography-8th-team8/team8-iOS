//
//  UIView+Border.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/10.
//

import UIKit

extension UIView {
  enum BorderEdge {
    case top
    case right
    case bottom
    case left
  }
  
  func addBorder(edge: BorderEdge, color: UIColor, width: CGFloat = 1.0) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    
    switch edge {
    case .top:
      border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: width)
    case .right:
      border.frame = CGRect(x: frame.size.width - width, y: 0, width: width, height: frame.size.height)
    case .bottom:
      border.frame = CGRect(x: 0, y: frame.size.height - width, width: frame.size.width, height: width)
    case .left:
      border.frame = CGRect(x: 0, y: 0, width: width, height: frame.size.height)
    }
    
    self.layer.addSublayer(border)
  }
  
  func addBorders(edges: [BorderEdge], color: UIColor, width: CGFloat = 1.0) {
    edges.forEach {
      addBorder(edge: $0, color: color, width: width)
    }
  }
}
