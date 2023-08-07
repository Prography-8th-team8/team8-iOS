//
//  Bookmark.swift
//  CAKK
//
//  Created by Mason Kim on 2023/08/07.
//

import Foundation

struct Bookmark: Decodable, Hashable {
  let id: Int
  let name: String
  let district: District
  let location: String
  let imageUrls: [String]
}

// MARK: - Model Mapping

import RealmSwift

extension Bookmark {
  func toEntity() -> BookmarkEntity {
    let imageUrls = imageUrls.reduce(into: List<String>(), { result, imageUrl in
      result.append(imageUrl)
    })
    
    return BookmarkEntity(id: id,
                          name: name,
                          district: district.rawValue,
                          location: location,
                          imageUrls: imageUrls)
  }
}
