//
//  ShopDetailViewModel.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/13.
//

import Foundation

import Combine

final class ShopDetailViewModel {
  
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
    let naverMapRouteURL = CurrentValueSubject<URL?, Never>(nil)
  }
  
  
  // MARK: - Properties
  
  let input: Input
  let output: Output
  
  private let service: NetworkService<CakeAPI>
  private let realmStorage: RealmStorageProtocol
  
  private let cakeShop: CakeShop
  
  private var numberOfBlogPostsToShow = 3
  private static let maximumNumberOfBlogPosts = 30 // 최대로 보여줄 블로그포스트 수
  
  private var cancellableBag = Set<AnyCancellable>()
  
  
  // MARK: - Initialization
  
  init(cakeShop: CakeShop,
       service: NetworkService<CakeAPI>,
       realmStorage: RealmStorageProtocol) {
    self.service = service
    self.cakeShop = cakeShop
    self.realmStorage = realmStorage
    
    self.input = Input()
    self.output = Output()
    
    bindInputs(input, output)
  }
  
  
  // MARK: - Private
  
  private func bindInputs(_ input: Input, _ output: Output) {
    bindFetchCakeShopDetail(input, output)
    bindLoadMoreBlogPosts(input, output)
    bindBookmark(input, output)
    bindRoute(input, output)
  }
  
  private func bindFetchCakeShopDetail(_ input: Input, _ output: Output) {
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
  }
  
  private func bindLoadMoreBlogPosts(_ input: Input, _ output: Output) {
    input.loadMoreBlogPosts
      .prepend(()) // 초기에 한 번 값을 발행
      .filter { [weak self] in
        // 30개 이상은 블로그 포스팅을 fetch 하지 않음
        (self?.numberOfBlogPostsToShow ?? 0) < Self.maximumNumberOfBlogPosts
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
  }
  
  private func bindBookmark(_ input: Input, _ output: Output) {
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
          let isSuccess = self.realmStorage.remove(id: cakeShop.id, entityType: CakeShopEntity.self)
          
          if isBookmarked {
            output.isBookmarked.send(false)
          }
        } else {
          // 북마크가 되어 있지 않았으면 북마크 추가
          let entity = self.cakeShop.toEntity(isBookmarked: true)
          let isSuccess = self.realmStorage.save(entity)
          
          if isSuccess {
            output.isBookmarked.send(true)
          }
        }
      }
      .store(in: &cancellableBag)
  }
  
  private func bindRoute(_ input: Input, _ output: Output) {
    output.cakeShopDetail.sink { shopDetail in
      guard let shopDetail = shopDetail else { return }
      
      guard var urlComponents = URLComponents(string: "nmap://route/public") else { return }
      urlComponents.queryItems = [
        URLQueryItem(name: "dlat", value: String(shopDetail.latitude)),
        URLQueryItem(name: "dlng", value: String(shopDetail.longitude)),
        URLQueryItem(name: "dname", value: shopDetail.name),
        URLQueryItem(name: "appname", value: Bundle.main.bundleIdentifier)
      ]
      guard let url = urlComponents.url else { return }
      
      output.naverMapRouteURL.send(url)
    }
    .store(in: &cancellableBag)
  }
  
}
