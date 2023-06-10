//
//  String+RemovingHTMLTags.swift
//  CAKK
//
//  Created by Mason Kim on 2023/06/11.
//

import Foundation

extension String {
  func removingHTMLTags() -> String {
    replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
  }
}
