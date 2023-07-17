//
//  CakeShopCollectionCellModel.swift
//  CAKK
//
//  Created by 이승기 on 2023/07/17.
//

import UIKit

import Combine

class CakeShopCollectionCellModel {
  
  // MARK: - Properties
  
  struct Input {
    let configure = PassthroughSubject<Void, Never>()
  }
  
  struct Output {
    let shopName = PassthroughSubject<String, Never>()
    let district = PassthroughSubject<District, Never>()
    let location = PassthroughSubject<String, Never>()
    let categories = PassthroughSubject<[CakeCategory], Never>()
    let imageUrls = PassthroughSubject<[String], Never>()
  }
  
  let input: Input
  let output: Output
  private var cancellableBag = Set<AnyCancellable>()
  
  private let cakeShop: CakeShop
  private let service: NetworkService<CakeAPI>
  
  
  // MARK: - Initializers
  
  init(cakeShop: CakeShop, service: NetworkService<CakeAPI>) {
    self.cakeShop = cakeShop
    self.service = service
    
    self.input = Input()
    self.output = Output()
    bind(input, output)
  }
  
  
  // MARK: - Binds
  
  private func bind(_ input: Input, _ output: Output) {
    bindShopName(input, output: output)
    bindDistrictName(input, output: output)
    bindLocation(input, output: output)
    bindCakeShopCategory(input, output)
    bindImageUrls(input, output)
  }
  
  private func bindShopName(_ input: Input, output: Output) {
    let cakeShop = cakeShop
    
    input.configure
      .map { cakeShop.name }
      .sink { name in
        output.shopName.send(name)
      }
      .store(in: &cancellableBag)
  }
  
  private func bindDistrictName(_ input: Input, output: Output) {
    let cakeShop = cakeShop
    
    input.configure
      .map { cakeShop.district }
      .sink { district in
        output.district.send(district)
      }
      .store(in: &cancellableBag)
  }
  
  private func bindLocation(_ input: Input, output: Output) {
    let cakeShop = cakeShop
    
    input.configure
      .map { cakeShop.location }
      .sink { location in
        output.location.send(location)
      }
      .store(in: &cancellableBag)
  }
  
  private func bindCakeShopCategory(_ input: Input, _ output: Output) {
    let cakeShop = cakeShop
    
    input.configure
      .flatMap { [weak self] _ -> AnyPublisher<CakeCategoryResponse, Error> in
        guard let self else { return Empty().eraseToAnyPublisher() }
        return self.service.request(.fetchCakeCategory(id: cakeShop.id), type: CakeCategoryResponse.self)
      }
      .receive(on: DispatchQueue.main)
      .sink { completion in
        switch completion {
        case .finished:
          break
        case .failure(let error):
          output.categories.send([])
          print(error)
        }
      } receiveValue: { response in
        output.categories.send(response.categories)
      }
      .store(in: &cancellableBag)
  }
  
  private func bindImageUrls(_ input: Input, _ output: Output) {
    let cakeShop = cakeShop
    
    input.configure
      .map { cakeShop.imageUrls }
      .sink { imageUrls in
        output.imageUrls.send(imageUrls)
      }
      .store(in: &cancellableBag)
  }
  
//  func isBookmarked(id: Int) -> Bool {
//    return storage.load(id: id, entityType: CakeShopEntity.self) != nil
//  }
}
