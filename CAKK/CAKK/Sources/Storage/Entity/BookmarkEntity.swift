//
//  CakeShopEntity.swift
//  CAKK
//
//  Created by Mason Kim on 2023/06/30.
//

import RealmSwift

final class BookmarkEntity: Object {
  @Persisted(primaryKey: true) var id: Int
  @Persisted var name: String
  @Persisted var district: String
  @Persisted var location: String
  @Persisted var imageUrls: List<String>
  
  convenience init(id: Int,
                   name: String,
                   district: String,
                   location: String,
                   imageUrls: List<String>) {
    self.init()
    self.id = id
    self.name = name
    self.district = district
    self.location = location
    self.imageUrls = imageUrls
  }
}


// MARK: - Model Mapping

extension BookmarkEntity {
  func toModel() -> Bookmark {
    return Bookmark(id: id,
                    name: name,
                    district: District(rawValue: district) ?? .dobong,
                    location: location,
                    imageUrls: Array(imageUrls))
      }
}
