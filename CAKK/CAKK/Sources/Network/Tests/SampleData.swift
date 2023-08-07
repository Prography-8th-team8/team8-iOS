//
//  SampleData.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/07.
//

import Foundation

enum SampleData {
  
  // MARK: - cake shop list
  
  static let cakeShopListData: Data! = {
    let location = Bundle.main.url(forResource: "cake_shop_list_sample", withExtension: "json")!
    return try? Data(contentsOf: location)
  }()
  
  static let cakeShopList: [CakeShop]! = {
    return try? JSONDecoder().decode(CakeShopResponse.self, from: SampleData.cakeShopListData)
  }()
  
  
  // MARK: - cake shop detail
  
  static let cakeShopDetailData: Data! = {
    let location = Bundle.main.url(forResource: "cake_shop_detail_sample", withExtension: "json")!
    return try? Data(contentsOf: location)
  }()
  
  static let cakeShopDetail: CakeShopDetailResponse! = {
    return try? JSONDecoder().decode(CakeShopDetailResponse.self, from: SampleData.cakeShopDetailData)
  }()
  
  
  // MARK: - district count
  
  static let districtCountData: Data! = {
    let location = Bundle.main.url(forResource: "district_count_sample", withExtension: "json")!
    return try? Data(contentsOf: location)
  }()
  
  static let districtCount: DistrictCountResponse! = {
    return try? JSONDecoder().decode(DistrictCountResponse.self, from: SampleData.districtCountData)
  }()
  
  
  // MARK: - blog posts
  
  static let blogPostsData: Data! = {
    let blogPosts = Bundle.main.url(forResource: "blog_post_sample", withExtension: "json")!
    return try? Data(contentsOf: blogPosts)
  }()
  
  static let blogPosts: BlogPostResponse! = {
    return try? JSONDecoder().decode(BlogPostResponse.self, from: SampleData.blogPostsData)
  }()
  
  
  // MARK: - cake category
  
  static let cakeCategoryData: Data! = {
    let resource = Bundle.main.url(forResource: "cake_category_sample", withExtension: "json")!
    return try? Data(contentsOf: resource)
  }()
  
  static let cakeCategory: CakeCategoryResponse! = {
    return try? JSONDecoder().decode(CakeCategoryResponse.self, from: SampleData.cakeCategoryData)
  }()
  
  
  // MARK: - Feed
  
  static let feedData: Data! = {
    let resource = Bundle.main.url(forResource: "feed_image_sample", withExtension: "json")!
    return try? Data(contentsOf: resource)
  }()
  
  static let feed: FeedResponse! = {
    return try? JSONDecoder().decode(FeedResponse.self, from: SampleData.feedData)
  }()
  
  // MARK: - Bookmark
  
  static let bookmarkData: Data! = {
    let resource = Bundle.main.url(forResource: "bookmark_sample", withExtension: "json")!
    return try? Data(contentsOf: resource)
  }()
  
  static let bookmark: Bookmark! = {
    return try? JSONDecoder().decode(Bookmark.self, from: SampleData.bookmarkData)
  }()
}
