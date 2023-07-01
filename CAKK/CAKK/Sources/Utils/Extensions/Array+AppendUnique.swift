//
//  Array+AppendUnique.swift
//  CAKK
//
//  Created by 이승기 on 2023/07/01.
//

import Foundation

extension Array where Element: Hashable {
  mutating func appendUnique(contentsOf array: [Element]) {
    let uniqueElements = Set(array)
    let existingElements = Set(self)
    let nonDuplicateElements = uniqueElements.subtracting(existingElements)
    append(contentsOf: nonDuplicateElements)
  }
}
