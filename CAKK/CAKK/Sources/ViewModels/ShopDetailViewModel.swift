//
//  ShopDetailViewModel.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/13.
//

import Foundation
import Combine

final class ShopDetailViewModel: ViewModelType {
  struct Input {
    let viewDidLoad = PassthroughSubject<Void, Never>()
  }
  
  struct Output {
    let cakeShopDetail = PassthroughSubject<CakeShopDetailResponse, Never>()
    let failToFetchDetail = PassthroughSubject<Void, Never>()
  }
  
  // MARK: - Properties
  
  private(set) var input: Input!
  private(set) var output: Output!
  
  private let service: NetworkService<CakeAPI>
  
  private let cakeShop: CakeShop
  
  private var cancellableBag = Set<AnyCancellable>()
  
  // MARK: - LifeCycle
  
  init(cakeShop: CakeShop, service: NetworkService<CakeAPI>) {
    self.service = service
    self.cakeShop = cakeShop
    
    bindInputs()
  }
  
  // MARK: - Private
  
  private func bindInputs() {
    let input = Input()
    let output = Output()
    
    input.viewDidLoad
      .flatMap { [weak service] in
        return service?.request(
          .fetchCakeShopDetail(id: self.cakeShop.id),
          type: CakeShopDetailResponse.self) ?? Empty().eraseToAnyPublisher()
      }
      .sink(receiveCompletion: { completion in
        if case .failure = completion {
          output.failToFetchDetail.send()
        }
      }, receiveValue: { cakeShopDetail in
        output.cakeShopDetail.send(cakeShopDetail)
      })
      .store(in: &cancellableBag)
    
    self.input = input
    self.output = output
  }
}
