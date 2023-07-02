//
//  PostedCakeShopUserDefault.swift
//  CakkCategoryUploader
//
//  Created by 이승기 on 2023/06/26.
//

import Combine

class PostedCakeShopUserDefault: ObservableObject {

  // MARK: - Properties
  
  static let shared = PostedCakeShopUserDefault()
  
  @Published var publishedValue = [String: Bool]()
  
  @UserDefault(key: "cakeshop.posted", defaultValue: [String: Bool]())
  private(set) var value: [String: Bool]
  
  
  // MARK: - Initializers
  
  private init() {
    publishedValue = value
  }
  
  
  // MARK: - Methods
  
  public func add(_ cakeShop: CakeShop) {
    value[cakeShop.name] = true
    publishedValue[cakeShop.name] = true
  }
}
