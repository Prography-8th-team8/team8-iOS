//
//  Bookmark.swift
//  CAKK
//
//  Created by Mason Kim on 2023/08/07.
//

import Foundation

struct Bookmark: Decodable {
  let id: Int
  let name: String
  let district: District
  let location: String
  let imageUrls: [String]
}
