//
//  PostingViewStore.swift
//  CakkCategoryUploader
//
//  Created by 이승기 on 2023/06/26.
//

import SwiftUI
import Combine

import Moya
import CombineMoya

class PostingViewStore: ObservableObject {
  
  // MARK: - Properties
  
  private let provider = MoyaProvider<CakkCategoryAPI>()
  private var cancellables = Set<AnyCancellable>()
  
  private var selectedCategory = [CakeCategory]()
  public var selectedCategoryNames: String {
    return selectedCategory
      .map { $0.localizedString }
      .joined(separator: ", ")
  }

  @Published var cakeShop: CakeShop
  @Published var categories = CakeCategory.allCases
  @Published var isSuccessToUpload = false
  @Published var isFailedToUpload = false
  
  
  // MARK: - Initializers
  
  init(cakeShop: CakeShop) {
    _cakeShop = .init(wrappedValue: cakeShop)
  }
  
  
  // MARK: - Methods
  
  public func add(_ category: CakeCategory) {
    selectedCategory.append(category)
  }
  
  public func remove(_ category: CakeCategory) {
    if let index = selectedCategory.firstIndex(of: category) {
      selectedCategory.remove(at: index)
    }
  }
  
  public func post() {
    isSuccessToUpload = false
    isFailedToUpload = false
    
    provider
      .requestPublisher(.postCategory(storeName: cakeShop.name, categories: selectedCategory))
      .receive(on: DispatchQueue.main)
      .sink { _ in
        
      } receiveValue: { [weak self] response in
        if response.statusCode == 200 {
          self?.isSuccessToUpload = true
        } else {
          self?.isFailedToUpload = true
          print("❌", response.statusCode)
        }
      }
      .store(in: &cancellables)

    PostedCakeShopUserDefault.shared.add(cakeShop)
  }
  
  public func isSelected(_ category: CakeCategory) -> Bool {
    if selectedCategory.firstIndex(of: category) != nil {
      return true
    }
    
    return false
  }
}
