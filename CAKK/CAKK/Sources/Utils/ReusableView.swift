//
//  ReusableView.swift
//  CAKK
//
//  Created by Mason Kim on 2023/04/03.
//

import UIKit

protocol ReusableView {
  static var reuseIdentifier: String { get }
}

extension ReusableView {
  static var reuseIdentifier: String {
    String(describing: self)
  }
}
