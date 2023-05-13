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
    let viewWillShow = PassthroughSubject<Void, Never>()
  }
  
  struct Output {
    let cakeShopDetail = PassthroughSubject<CakeShopDetailResponse, Never>()
  }
  
  // MARK: - Properties
  
  var input: Input = Input()
  var output: Output = Output()
  
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
    input.viewWillShow
      .flatMap {
        self.service.request(.fetchCakeShopDetail(id: self.cakeShop.id),
                             type: CakeShopDetailResponse.self)
      }
      .catch { _ in
        return Empty<CakeShopDetailResponse, Never>()
      }
      .sink {
        self.output.cakeShopDetail.send($0)
      }
      .store(in: &cancellableBag)
  }
}
