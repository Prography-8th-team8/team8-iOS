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
    let apply = PassthroughSubject<Void, Never>()
    let refresh = PassthroughSubject<Void, Never>()
    let selectItem = PassthroughSubject<IndexPath, Never>()
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
  
  
  // MARK: - Public
  
  public func isSelected(_ category: CakeCategory) -> Bool {
    return output.categories.value.contains(category)
  }

  
  // MARK: - Private
  
  private func bind(_ input: Input, _ output: Output) {
    bindApply(input, output)
    bindCategoryChanges(input, output)
    bindRefresh(input, output)
    bindItemSelect(input, output)
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
        
        if Set(self.originalFilteredCategories) == Set(categories) {
          output.categoriesChanged.send(false)
        } else {
          output.categoriesChanged.send(true)
        }
      }
      .store(in: &cancellableBag)
  }
  
  private func bindRefresh(_ input: Input, _ output: Output) {
    input
      .refresh
      .sink { _ in
        output.categories.send([])
      }
      .store(in: &cancellableBag)
  }
  
  private func bindItemSelect(_ input: Input, _ output: Output) {
    input
      .selectItem
      .map { CakeCategory.allCases[$0.row] }
      .sink { selectedItem in
        if output.categories.value.contains(selectedItem) {
          if let index = output.categories.value.firstIndex(of: selectedItem) {
            output.categories.value.remove(at: index)
          }
        } else {
          output.categories.value.append(selectedItem)
        }
      }
      .store(in: &cancellableBag)
  }
}
