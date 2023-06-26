//
//  PostingViewStore.swift
//  CakkCategoryUploader
//
//  Created by 이승기 on 2023/06/26.
//

import SwiftUI

class PostingViewStore: ObservableObject {
  
  private var selectedCategory = [CakeCategory]()

  @Published var cakeShop: CakeShop
  @Published var categories = CakeCategory.allCases
  @Published var isSuccessToUpload = false
  
  
  init(cakeShop: CakeShop) {
    _cakeShop = .init(wrappedValue: cakeShop)
  }
  
  
  public func add(_ category: CakeCategory) {
    selectedCategory.append(category)
  }
  
  public func remove(_ category: CakeCategory) {
    if let index = selectedCategory.firstIndex(of: category) {
      selectedCategory.remove(at: index)
    }
  }
  
  public func post() {
    isSuccessToUpload = true
    
    PostedCakeShopUserDefault.shared.add(cakeShop)
  }
  
  public func isSelected(_ category: CakeCategory) -> Bool {
    if let index = selectedCategory.firstIndex(of: category) {
      return true
    }
    
    return false
  }
}
