//
//  CakeCategoryResponse.swift
//  CAKK
//
//  Created by 이승기 on 2023/07/17.
//

import Foundation

struct CakeCategoryResponse: Decodable {
  let shopId: Int
  let categories: [CakeCategory]
  
  enum CodingKeys: String, CodingKey {
    case shopId = "storeId"
    case categories = "types"
  }
}
