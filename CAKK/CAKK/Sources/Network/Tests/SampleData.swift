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
  
  // TODO: 케이크샵 상세정보 - 아직 백엔드 명세가 나오지 않아, 리스트의 cakeShop과 동일한 데이터로 예시로만 꽂아놓음
  static let cakeShopDetailData: Data! = {
    let location = Bundle.main.url(forResource: "cake_shop_detail_sample", withExtension: "json")!
    return try? Data(contentsOf: location)
  }()
  
  static let cakeShopList: [CakeShop]! = {
    return try? JSONDecoder().decode(CakeShopResponse.self, from: SampleData.cakeShopListData).cakeShops
  }()
  
  static let cakeShopDetail: CakeShopDetailResponse! = {
    return try? JSONDecoder().decode(CakeShopDetailResponse.self, from: SampleData.cakeShopDetailData)
  }()
}
