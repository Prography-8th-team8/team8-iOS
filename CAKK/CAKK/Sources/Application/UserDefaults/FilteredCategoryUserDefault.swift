//
//  FilteredCategoryUserDefault.swift
//  CAKK
//
//  Created by 이승기 on 2023/06/24.
//

import Foundation
import Combine

class FilteredCategoryUserDefault {
  
  // MARK: - Properties
  
  static let key = "category.filter"
  static let shared = FilteredCategoryUserDefault()
  
  public var filteredCategoryPublisher = PassthroughSubject<[CakeCategory], Never>()
  
  private(set) var categories: [CakeCategory] {
    didSet {
      UserDefaults.standard.setValue(categories.map { $0.rawValue }, forKey: Self.key)
    }
  }
  
  
  // MARK: - Initializers
  
  private init() {
    if let value = UserDefaults.standard.array(forKey: Self.key) as? [String] {
      categories = value.compactMap { CakeCategory(rawValue: $0) }
    } else {
      // default value
      categories = []
    }
  }
  
  
  // MARK: - Methods
  
  public func update(filteredCategories: [CakeCategory]) {
    categories = filteredCategories
    // notify
    filteredCategoryPublisher.send(filteredCategories)
  }
}
