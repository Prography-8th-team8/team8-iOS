//
//  CakeShopDetailResponse.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/13.
//

import Foundation

struct CakeShopDetailResponse: Decodable {
  let id: Int
  let createdAt: String
  let modifiedAt: String
  let name: String
  let city: String
  let district: District
  let latitude: Double
  let longitude: Double
  let thumbnail: String?
  let imageUrls: [String]
  let cakeCategories: [CakeCategory]
  let link: String
  let description: String
  let phoneNumber: String
  let address: String
  let blogPosts: [BlogPost]?
  
  enum CodingKeys: String, CodingKey {
    case id, createdAt, modifiedAt, name, city, district,
         latitude, longitude, link, description, phoneNumber, address, blogPosts, thumbnail, imageUrls
    case cakeCategories = "storeTypes"
  }
}


// MARK: - Entity 매핑

extension CakeShopDetailResponse {
  func toBookmarkEntity() -> BookmarkEntity {
    return Bookmark(id: id,
                    name: name,
                    district: district,
                    location: address,
                    imageUrls: imageUrls).toEntity()
  }
}
