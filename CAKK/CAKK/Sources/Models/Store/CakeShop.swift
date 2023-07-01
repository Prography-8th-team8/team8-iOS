//
//  CakeShop.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/07.
//

import Foundation

import RealmSwift

typealias CakeShopResponse = [CakeShop]

struct CakeShop: Decodable, Hashable {
  let id: Int
  let createdAt: String
  let modifiedAt: String
  let name: String
  let city: String
  let district: District
  let location: String
  let latitude: Double
  let longitude: Double
  let cakeCategories: [CakeCategory]
  let url: String?
  
  enum CodingKeys: String, CodingKey {
    case id, createdAt, modifiedAt, name, city, district, location, latitude, longitude, url
    case cakeCategories = "storeTypes"
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}


// MARK: - Model Mapping

extension CakeShop {
  func toEntity(isBookmarked: Bool) -> CakeShopEntity {
    let cakeCategories = cakeCategories.reduce(into: List<String>(), { result, category in
      result.append(category.rawValue)
    })
    
    return CakeShopEntity(id: id,
                          isBookmarked: isBookmarked,
                          createdAt: createdAt,
                          modifiedAt: modifiedAt,
                          name: name,
                          city: city,
                          district: district.rawValue,
                          location: location,
                          latitude: latitude,
                          longitude: longitude,
                          cakeCategories: cakeCategories,
                          url: url)
  }
}
