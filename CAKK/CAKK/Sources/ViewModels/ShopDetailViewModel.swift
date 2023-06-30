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
    let loadMoreBlogPosts = PassthroughSubject<Void, Never>()
    let tapBookmarkButton = PassthroughSubject<Void, Never>()
  }
  
  struct Output {
    let cakeShopDetail = CurrentValueSubject<CakeShopDetailResponse?, Never>(nil)
    let blogPostsToShow = PassthroughSubject<[BlogPost], Never>()
    let failToFetchDetail = PassthroughSubject<Void, Never>()
    let isBookmarked = CurrentValueSubject<Bool, Never>(false)
  }
  
  
  // MARK: - Properties
  
  private(set) var input: Input!
  private(set) var output: Output!
  
  private let service: NetworkService<CakeAPI>
  private let realmStorage: RealmStorageProtocol
  
  private let cakeShop: CakeShop
  
  private var numberOfBlogPostsToShow = 3
  
  private var cancellableBag = Set<AnyCancellable>()
  
  
  // MARK: - Initialization
  
  init(cakeShop: CakeShop,
       service: NetworkService<CakeAPI>,
       realmStorage: RealmStorageProtocol) {
    self.service = service
    self.cakeShop = cakeShop
    self.realmStorage = realmStorage
    
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
    
    input.loadMoreBlogPosts
      .prepend(()) // 초기에 한 번 값을 발행
      .filter { [weak self] in
        // 15개 이상은 블로그 포스팅을 fetch 하지 않음
        (self?.numberOfBlogPostsToShow ?? 0) < 15
      }
      .flatMap { [weak self] in
        guard let self = self else { return Empty<BlogPostResponse, Error>().eraseToAnyPublisher() }
        return self.service.request(
          .fetchBlogReviews(id: self.cakeShop.id, numberOfPosts: self.numberOfBlogPostsToShow),
          type: BlogPostResponse.self)
      }
      .sink(receiveCompletion: { completion in
        if case .failure(let error) = completion {
          print(error)
        }
      }, receiveValue: { [weak self] blogPostResponse in
        // 불필요한 HTML 태그를 지우고 내보냄
        let blogPostsWithoutHTMLTags = blogPostResponse.blogPosts.map {
          $0.removingHTMLTags()
        }
        output.blogPostsToShow.send(blogPostsWithoutHTMLTags)
        self?.numberOfBlogPostsToShow += 3
      })
      .store(in: &cancellableBag)
    
    input.viewDidLoad
      .sink { [weak self] in
        guard let self = self else { return }
        let isBookmarked = self.realmStorage.load(id: cakeShop.id, entityType: CakeShopEntity.self) != nil
        output.isBookmarked.send(isBookmarked)
      }
      .store(in: &cancellableBag)
    
    input.tapBookmarkButton
      .map {
        output.isBookmarked.value
      }
      .sink { [weak self] isBookmarked in
        guard let self = self else { return }
        
        // 이미 북마크가 되어 있었으면 북마크에서 삭제
        if isBookmarked {
          self.realmStorage.remove(id: cakeShop.id, entityType: CakeShopEntity.self)
          output.isBookmarked.send(false)
        } else {
          // 북마크가 되어 있지 않았으면 북마크 추가
          let entity = self.cakeShop.toEntity(isBookmarked: true)
          self.realmStorage.save(entity)
          output.isBookmarked.send(true)
        }
      }
      .store(in: &cancellableBag)
    
    self.input = input
    self.output = output
  }
}
