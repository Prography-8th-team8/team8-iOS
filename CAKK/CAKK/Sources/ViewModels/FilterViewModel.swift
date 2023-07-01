//
//  FilterViewModel.swift
//  CAKK
//
//  Created by 이승기 on 2023/06/24.
//

import Foundation

import Combine

final class FilterViewModel: ViewModelType {

  // MARK: - Properties
  
  struct Input {
    let addCategory = PassthroughSubject<CakeCategory, Never>()
    let removeCategory = PassthroughSubject<CakeCategory, Never>()
    let apply = PassthroughSubject<Void, Never>()
  }
  
  struct Output {
    let categories = CurrentValueSubject<[CakeCategory], Never>(FilteredCategoryUserDefault.shared.categories)
    let categoriesChanged = CurrentValueSubject<Bool, Never>(false)
  }
  
  private(set) var input: Input!
  private(set) var output: Output!
  private var cancellableBag = Set<AnyCancellable>()
  private let originalFilteredCategories = FilteredCategoryUserDefault.shared.categories
  
  
  // MARK: - Initializers
  
  init() {
    setupInputOutput()
  }

  
  // MARK: - Private
  
  private func setupInputOutput() {
    let input = Input()
    let output = Output()
    
    input
      .addCategory
      .sink { category in
        output.categories.value.append(category)
      }
      .store(in: &cancellableBag)
    
    input
      .removeCategory
      .sink { category in
        if let index = output.categories.value.firstIndex(of: category) {
          output.categories.value.remove(at: index)
        }
      }
      .store(in: &cancellableBag)
    
    input
      .apply
      .sink { _ in
        FilteredCategoryUserDefault.shared.update(filteredCategories: output.categories.value)
      }
      .store(in: &cancellableBag)
    
    output
      .categories
      .sink { [weak self] categories in
        guard let self else { return }
        
        if categories.isEmpty || Set(self.originalFilteredCategories) == Set(categories) {
          output.categoriesChanged.send(false)
        } else {
          output.categoriesChanged.send(true)
        }
      }
      .store(in: &cancellableBag)
    
    self.input = input
    self.output = output
  }
}
