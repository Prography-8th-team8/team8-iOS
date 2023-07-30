//
//  MyBookmarkViewModel.swift
//  CAKK
//
//  Created by Mason Kim on 2023/07/30.
//

import Foundation

import Combine


final class MyBookmarkViewModel: ViewModelType {
  
  // MARK: - Properties
  
  struct Input {
    let viewWillAppear = PassthroughSubject<Void, Never>()
  }
  
  struct Output {
    let myBookmarkCakeShops = CurrentValueSubject<[CakeShopEntity], Never>([])
  }
  
  let input: Input
  let output: Output
  private var cancellables = Set<AnyCancellable>()
  
  private let realmStorage: RealmStorageProtocol
  
  
  // MARK: - Initializers
  
  init(realmStorage: RealmStorageProtocol) {
    self.input = Input()
    self.output = Output()
    self.realmStorage = realmStorage
    
    bind(input, output)
  }
  
  
  // MARK: - Private
  
  private func bind(_ input: Input, _ output: Output) {
    input.viewWillAppear.sink { [weak self] in
      guard let self = self else { return }
      let cakeShpopEntities = realmStorage.loadAll(entityType: CakeShopEntity.self)
      output.myBookmarkCakeShops.send(cakeShpopEntities)
    }
    .store(in: &cancellables)
  }
}
