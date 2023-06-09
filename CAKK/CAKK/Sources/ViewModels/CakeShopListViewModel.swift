//
//  CakeShopListViewModel.swift
//  CAKK
//
//  Created by 이승기 on 2023/05/16.
//

import UIKit
import Combine

class CakeShopListViewModel: ViewModelType {
  
  // MARK: - Properties
  
  struct Input {
    let selectCakeShop = PassthroughSubject<IndexPath, Never>()
  }
  
  struct Output {
    let cakeShops = CurrentValueSubject<[CakeShop], Never>([])
    let presentCakeShopDetail = PassthroughSubject<CakeShop, Never>()
    let isLoading = CurrentValueSubject<Bool, Never>(false)
  }
  
  private(set) var input: Input!
  private(set) var output: Output!
  private var cancellableBag = Set<AnyCancellable>()
  
  private let initialCakeShops: [CakeShop]
  private let service: NetworkService<CakeAPI>
  
  
  // MARK: - LifeCycle
  
  init(initialCakeShops: [CakeShop],
       service: NetworkService<CakeAPI>) {
    self.initialCakeShops = initialCakeShops
    self.service = service
    
    setupInputOutput()
  }
  
  // MARK: - Privates

  private func setupInputOutput() {
    let input = Input()
    let output = Output()
    
    Just(Void())
      .sink { [weak self] _ in
        guard let self else { return }
        output.cakeShops.send(self.initialCakeShops)
      }
      .store(in: &cancellableBag)
    
    input.selectCakeShop
      .sink { indexPath in
        guard let cakeShop = output.cakeShops.value[safe: indexPath.row] else { return }
        output.presentCakeShopDetail.send(cakeShop)
      }
      .store(in: &cancellableBag)
    
    self.input = input
    self.output = output
  }
}
