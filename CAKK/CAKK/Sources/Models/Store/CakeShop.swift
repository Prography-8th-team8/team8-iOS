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
  let district: District  // TODO: 해당 데이터를 District 타입으로 만들 수 있을 것 같은데, 백엔드 명세서의 예시 데이터가 나오지 않아 아직 알 수 없음...
  let location: String
  let latitude: Double
  let longitude: Double
  let cakeShopTypes: [CakeShopType]
  
  enum CodingKeys: String, CodingKey {
    case id, createdAt, modifiedAt, name, city, district, location, latitude, longitude
    case cakeShopTypes = "storeTypes"
  }
}
