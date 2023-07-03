//
//  FilterViewModel.swift
//  CAKK
//
//  Created by 이승기 on 2023/06/24.
//

import Foundation

import Combine

final class FilterViewModel {

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
  
  let input: Input
  let output: Output
  private var cancellableBag = Set<AnyCancellable>()
  private let originalFilteredCategories = FilteredCategoryUserDefault.shared.categories
  
  
  // MARK: - Initializers
  
  init() {
    self.input = Input()
    self.output = Output()
    
    bind(input, output)
  }

  
  // MARK: - Private
  
  private func bind(_ input: Input, _ output: Output) {
    bindAddCategory(input, output)
    bindRemoveCategory(input, output)
    bindApply(input, output)
    bindCategoryChanges(input, output)
  }
  
  private func bindAddCategory(_ input: Input, _ output: Output) {
    input
      .addCategory
      .sink { category in
        output.categories.value.append(category)
      }
      .store(in: &cancellableBag)
  }
  
  private func bindRemoveCategory(_ input: Input, _ output: Output) {
    input
      .removeCategory
      .sink { category in
        if let index = output.categories.value.firstIndex(of: category) {
          output.categories.value.remove(at: index)
        }
      }
      .store(in: &cancellableBag)
  }
  
  private func bindApply(_ input: Input, _ output: Output) {
    input
      .apply
      .sink { _ in
        FilteredCategoryUserDefault.shared.update(filteredCategories: output.categories.value)
      }
      .store(in: &cancellableBag)
  }
  
  private func bindCategoryChanges(_ input: Input, _ output: Output) {
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
  }
}
