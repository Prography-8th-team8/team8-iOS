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
    let tapBookmarkButton = PassthroughSubject<Void, Never>()
  }
  
  struct Output {
    let shopName = PassthroughSubject<String, Never>()
    let district = PassthroughSubject<District, Never>()
    let location = PassthroughSubject<String, Never>()
    let categories = PassthroughSubject<[CakeCategory], Never>()
    let imageUrls = PassthroughSubject<[String], Never>()
    let isBookmarked = CurrentValueSubject<Bool, Never>(false)
  }
  
  let input: Input
  let output: Output
  private var cancellableBag = Set<AnyCancellable>()
  
  private let cakeShop: CakeShop
  private let service: NetworkService<CakeAPI>
  private let realmStorage: RealmStorageProtocol
  
  
  // MARK: - Initializers
  
  init(cakeShop: CakeShop,
       service: NetworkService<CakeAPI>,
       realmStorage: RealmStorageProtocol) {
    self.cakeShop = cakeShop
    self.service = service
    self.realmStorage = realmStorage

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
    bindBookmark(input, output)
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
    let maxImageCounts = 4
    
    input.configure
      .map { Array(cakeShop.imageUrls.prefix(maxImageCounts)) }
      .sink { imageUrls in
        output.imageUrls.send(imageUrls)
      }
      .store(in: &cancellableBag)
  }
  
  private func bindBookmark(_ input: Input, _ output: Output) {
    let cakeShop = cakeShop
    
    input.configure
      .sink { [weak self] isBookmarked in
        guard let self else { return }
        
        let isBookmarked = self.realmStorage.load(id: cakeShop.id, entityType: CakeShopEntity.self) != nil
        output.isBookmarked.send(isBookmarked)
      }
      .store(in: &cancellableBag)
    
    input.tapBookmarkButton
      .map { output.isBookmarked.value }
      .sink { isBookmarked in
        if isBookmarked {
          // 북마크 삭제
          let successToRemove = self.realmStorage.remove(id: cakeShop.id, entityType: CakeShopEntity.self)
          
          if successToRemove {
            output.isBookmarked.send(false)
          }
        } else {
          // 북마크 추가
          let entity = cakeShop.toEntity(isBookmarked: true)
          let successToSave = self.realmStorage.save(entity)
          
          if successToSave {
            output.isBookmarked.send(true)
          }
        }
      }
      .store(in: &cancellableBag)
  }
}
