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
  
  func addBorder(to edge: BorderEdge, color: UIColor?, width: CGFloat = 1.0) {
    let borderView = UIView()
    borderView.translatesAutoresizingMaskIntoConstraints = false
    borderView.backgroundColor = color
    addSubview(borderView)
    
    let topConstraint = topAnchor.constraint(equalTo: borderView.topAnchor)
    let rightConstraint = trailingAnchor.constraint(equalTo: borderView.trailingAnchor)
    let bottomConstraint = bottomAnchor.constraint(equalTo: borderView.bottomAnchor)
    let leftConstraint = leadingAnchor.constraint(equalTo: borderView.leadingAnchor)
    let heightConstraint = borderView.heightAnchor.constraint(equalToConstant: width)
    let widthConstraint = borderView.widthAnchor.constraint(equalToConstant: width)
    
    switch edge {
    case .top:
      NSLayoutConstraint.activate([leftConstraint, topConstraint, rightConstraint, heightConstraint])
    case .right:
      NSLayoutConstraint.activate([topConstraint, rightConstraint, bottomConstraint, widthConstraint])
    case .bottom:
      NSLayoutConstraint.activate([rightConstraint, bottomConstraint, leftConstraint, heightConstraint])
    case .left:
      NSLayoutConstraint.activate([bottomConstraint, leftConstraint, topConstraint, widthConstraint])
    }
  }
  
  func addBorders(to edges: [BorderEdge], color: UIColor?, width: CGFloat = 1.0) {
    edges.forEach {
      addBorder(to: $0, color: color, width: width)
    }
  }
}
