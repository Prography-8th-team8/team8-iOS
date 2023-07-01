//
//  CakeShopEntity.swift
//  CAKK
//
//  Created by Mason Kim on 2023/06/30.
//

import RealmSwift

final class CakeShopEntity: Object {
  @Persisted(primaryKey: true) var id: Int
  @Persisted var isBookmarked: Bool
  @Persisted var createdAt: String
  @Persisted var modifiedAt: String
  @Persisted var name: String
  @Persisted var city: String
  @Persisted var district: String
  @Persisted var location: String
  @Persisted var latitude: Double
  @Persisted var longitude: Double
  @Persisted var cakeCategories: List<String>
  @Persisted var url: String?
  
  convenience init(id: Int,
                   isBookmarked: Bool,
                   createdAt: String,
                   modifiedAt: String,
                   name: String,
                   city: String,
                   district: String,
                   location: String,
                   latitude: Double,
                   longitude: Double,
                   cakeCategories: List<String>,
                   url: String? = nil) {
    self.init()
    self.id = id
    self.isBookmarked = isBookmarked
    self.createdAt = createdAt
    self.modifiedAt = modifiedAt
    self.name = name
    self.city = city
    self.district = district
    self.location = location
    self.latitude = latitude
    self.longitude = longitude
    self.cakeCategories = cakeCategories
    self.url = url
  }
}


// MARK: - Model Mapping

extension CakeShopEntity {
  func toModel() -> CakeShop {
    return CakeShop(id: id,
                    createdAt: createdAt,
                    modifiedAt: modifiedAt,
                    name: name,
                    city: city,
                    district: District(rawValue: district) ?? .dobong,
                    location: location,
                    latitude: latitude,
                    longitude: longitude,
                    cakeCategories: cakeCategories.compactMap { CakeCategory(rawValue: $0) },
                    url: url)
      }
}
