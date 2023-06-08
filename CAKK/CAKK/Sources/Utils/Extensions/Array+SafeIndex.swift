//
//  Array+SafeIndex.swift
//  CAKK
//
//  Created by Mason Kim on 2023/06/04.
//

import Foundation

extension Array {
  subscript(safe index: Int) -> Element? {
    return indices ~= index ? self[index] : nil
  }
}
