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
  }
  
  struct Output {
    let cakeShopDetail = PassthroughSubject<CakeShopDetailResponse, Never>()
    let blogPostsToShow = PassthroughSubject<[BlogPost], Never>()
    let failToFetchDetail = PassthroughSubject<Void, Never>()
  }
  
  // MARK: - Properties
  
  private(set) var input: Input!
  private(set) var output: Output!
  
  private let service: NetworkService<CakeAPI>
  
  private let cakeShop: CakeShop
  
  private var numberOfBlogPostsToShow = 3
  
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
    
    self.input = input
    self.output = output
  }
}
