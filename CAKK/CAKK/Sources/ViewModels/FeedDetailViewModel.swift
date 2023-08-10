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
    let viewDidLoad = PassthroughSubject<Void, Never>()
    let tapBookmarkButton = PassthroughSubject<Void, Never>()
    let tapVisitCakeShopButton = PassthroughSubject<Void, Never>()
  }
  
  struct Output {
    let storeName = CurrentValueSubject<String, Never>("")
    let isBookmarked = CurrentValueSubject<Bool, Never>(false)
    let imageUrls = CurrentValueSubject<[String], Never>([])
    let isCakeShopDetailShown = PassthroughSubject<Int, Never>()
    let district = CurrentValueSubject<String, Never>("")
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
    bindDistrict(input, output)
    bindCakeShopDetail(input, output)
    bindBookmark(input, output)
  }
  
  private func bindShopName(_ input: Input, _ output: Output) {
    output.storeName.send(feed.storeName)
  }
  
  private func bindImages(_ input: Input, _ output: Output) {
    output.imageUrls.send([feed.imageUrl])
  }
  
  private func bindDistrict(_ input: Input, _ output: Output) {
    output.district.send(feed.district.koreanName)
  }
  
  private func bindCakeShopDetail(_ input: Input, _ output: Output) {
    let cakeShopId = feed.storeId
    
    input.tapVisitCakeShopButton
      .sink {
        output.isCakeShopDetailShown.send(cakeShopId)
      }
      .store(in: &cancellableBag)
  }
  
  private func bindBookmark(_ input: Input, _ output: Output) {
    let cakeShopId = feed.storeId
    
    input.viewDidLoad
      .sink { [weak self] in
        guard let self = self else { return }
        let isBookmarked = self.realmStorage.load(id: self.feed.storeId, entityType: BookmarkEntity.self) != nil
        output.isBookmarked.send(isBookmarked)
      }
      .store(in: &cancellableBag)
    
    input.tapBookmarkButton
      .map { output.isBookmarked.value }
      .sink { [weak self] isBookmarked in
        guard let self = self else { return }
        
        if isBookmarked {
          // 이미 북마크가 되어 있었으면 북마크에서 삭제
          let successToRemove = realmStorage.remove(id: self.feed.storeId, entityType: BookmarkEntity.self)
          if successToRemove {
            output.isBookmarked.send(false)
          }
        } else {
          // 북마크가 되어 있지 않았으면 북마크 추가
          service.request(.fetchBookmark(id: cakeShopId), type: Bookmark.self)
            .sink { completion in
              print(completion)
            }
            receiveValue: { bookmark in
              let successToSave = self.realmStorage.save(bookmark.toEntity())
              
              if successToSave {
                output.isBookmarked.send(true)
              }
            }
            .store(in: &cancellableBag)
        }
      }
      .store(in: &cancellableBag)
  }
}
