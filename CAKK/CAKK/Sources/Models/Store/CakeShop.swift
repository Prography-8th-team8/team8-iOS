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
  let location: String
  let latitude: Double
  let longitude: Double
  let cakeCategories: [CakeCategory]
  let url: String?
  
  enum CodingKeys: String, CodingKey {
    case id, createdAt, modifiedAt, name, city, district, location, latitude, longitude, url
    case cakeCategories = "storeTypes"
  }
}
