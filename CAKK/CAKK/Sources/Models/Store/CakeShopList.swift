//
//  StoreList.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/07.
//

import Foundation

struct CakeShopList: Decodable {
  let cakeShops: [CakeShop]
  
  enum CodingKeys: String, CodingKey {
    case cakeShops = "storeList"
  }
}
