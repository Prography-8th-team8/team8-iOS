//
//  SampleData.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/07.
//

import Foundation

enum SampleData {
  static let cakeShopListData: Data! = {
    let location = Bundle.main.url(forResource: "cake_shop_list_sample", withExtension: "json")!
    return try? Data(contentsOf: location)
  }()
  
  static let cakeShopList: [CakeShop]! = {
    return try? JSONDecoder().decode(CakeShopResponse.self, from: SampleData.cakeShopListData).cakeShops
  }()
}
