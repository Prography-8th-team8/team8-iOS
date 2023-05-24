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
  let city: String
  let district: District
  let latitude: Double
  let longitude: Double
  let cakeShopTypes: [CakeShopType]
  
  enum CodingKeys: String, CodingKey {
    case id, createdAt, modifiedAt, name, city, district, latitude, longitude
    case cakeShopTypes = "storeTypes"
  }
}
