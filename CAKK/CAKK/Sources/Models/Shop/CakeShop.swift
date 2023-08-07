//
//  CakeShop.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/07.
//

import Foundation

typealias CakeShopResponse = [CakeShop]

struct CakeShop: Decodable, Hashable {
  let id: Int
  let createdAt: String
  let modifiedAt: String
  let name: String
  let shareLink: String?
  let city: String
  let district: District
  let location: String
  let latitude: Double
  let longitude: Double
  let thumbnail: String?
  let imageUrls: [String]
  let cakeCategories: [CakeCategory]
  
  enum CodingKeys: String, CodingKey {
    case id, createdAt, modifiedAt, name, shareLink, city, district, location, latitude, longitude, thumbnail, imageUrls
    case cakeCategories = "storeTypes"
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(location)
  }
}

// MARK: - Model Mapping

extension CakeShop {
  func toBookmarkEntity() -> BookmarkEntity {
    return Bookmark(id: id,
                    name: name,
                    district: district,
                    location: location,
                    imageUrls: imageUrls).toEntity()
  }
}
