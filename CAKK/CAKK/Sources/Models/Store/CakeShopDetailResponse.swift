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
  let location: String
  let latitude: Double
  let longitude: Double
  let cakeShopTypes: [CakeShopType]
  let link: String
  let description: String
  let phoneNumber: String
  let address: String
  
  enum CodingKeys: String, CodingKey {
    case id, createdAt, modifiedAt, name, city, district, location,
         latitude, longitude, link, description, phoneNumber, address
    case cakeShopTypes = "storeTypes"
  }
}
