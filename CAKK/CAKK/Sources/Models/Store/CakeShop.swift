//
//  CakeShop.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/07.
//

import Foundation

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
  let cakeShopTypes: [CakeShopType]
  
  enum CodingKeys: String, CodingKey {
    case id, createdAt, modifiedAt, name, city, district, location, latitude, longitude
    case cakeShopTypes = "storeTypes"
  }
}
