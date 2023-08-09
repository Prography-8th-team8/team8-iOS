//
//  FeedDetailViewModel.swift
//  CAKK
//
//  Created by 이승기 on 2023/08/02.
//

import UIKit

import Combine

final class FeedDetailViewModel {
  
  // MARK: - Properties
  
  struct Input {
    let tapHeartButton = PassthroughSubject<Void, Never>()
    let tapVisitCakeShopButton = PassthroughSubject<Void, Never>()
  }
  
  struct Output {
    let storeName = CurrentValueSubject<String, Never>("")
    let isBookmarked = CurrentValueSubject<Bool, Never>(false)
    let imageUrls = CurrentValueSubject<[String], Never>([])
    let isCakeShopDetailShown = PassthroughSubject<Int, Never>()
  }
  
  public let input: Input
  public let output: Output
  private var cancellableBag = Set<AnyCancellable>()
  
  private let service: NetworkService<CakeAPI>
  private let realmStorage: RealmStorageProtocol
  
  private let feed: Feed
  
  
  // MARK: - Initializers
  
  init(feed: Feed, service: NetworkService<CakeAPI>, storage: RealmStorageProtocol) {
    self.feed = feed
    self.service = service
    self.realmStorage = storage
    
    self.input = Input()
    self.output = Output()
    bind(input, output)
  }
  
  
  // MARK: - Binds
  
  private func bind(_ input: Input, _ output: Output) {
    bindShopName(input, output)
    bindImages(input, output)
    bindCakeShopDetail(input, output)
  }
  
  private func bindShopName(_ input: Input, _ output: Output) {
    output.storeName.send(feed.storeName)
  }
  
  private func bindImages(_ input: Input, _ output: Output) {
    output.imageUrls.send([feed.imageUrl])
  }
  
  private func bindCakeShopDetail(_ input: Input, _ output: Output) {
    let cakeShopId = feed.storeId
    
    input.tapVisitCakeShopButton
      .sink {
        output.isCakeShopDetailShown.send(cakeShopId)
      }
      .store(in: &cancellableBag)
  }
}
