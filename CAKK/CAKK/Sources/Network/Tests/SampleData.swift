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
  
  static let cakeShopDetailData: Data! = {
    let location = Bundle.main.url(forResource: "cake_shop_detail_sample", withExtension: "json")!
    return try? Data(contentsOf: location)
  }()
  
  static let districtCountData: Data! = {
    let location = Bundle.main.url(forResource: "district_count_sample", withExtension: "json")!
    return try? Data(contentsOf: location)
  }()
  
  static let blogPostsData: Data! = {
    let blogPosts = Bundle.main.url(forResource: "blog_post_sample", withExtension: "json")!
    return try? Data(contentsOf: blogPosts)
  }()
  
  static let cakeShopList: [CakeShop]! = {
    return try? JSONDecoder().decode(CakeShopResponse.self, from: SampleData.cakeShopListData)
  }()
  
  static let cakeShopDetail: CakeShopDetailResponse! = {
    return try? JSONDecoder().decode(CakeShopDetailResponse.self, from: SampleData.cakeShopDetailData)
  }()
  
  static let districtCount: DistrictCountResponse! = {
    return try? JSONDecoder().decode(DistrictCountResponse.self, from: SampleData.districtCountData)
  }()
  
  static let blogPosts: BlogPostResponse! = {
    return try? JSONDecoder().decode(BlogPostResponse.self, from: SampleData.blogPostsData)
  }()
}
