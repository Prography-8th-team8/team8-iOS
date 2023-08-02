//
//  FeedViewModel.swift
//  CAKK
//
//  Created by 이승기 on 2023/07/30.
//

import UIKit

import Combine

final class FeedViewModel {
  
  // MARK: - Properties
  
  struct Input {
    let didSelectItem = PassthroughSubject<IndexPath, Never>()
  }
  
  struct Output {
    let feedData = CurrentValueSubject<[Feed], Never>([])
    let isLoading = PassthroughSubject<Bool, Never>()
    let showFeedDetail = PassthroughSubject<Feed, Never>()
  }
  
  let input: Input
  let output: Output
  private var cancellableBag = Set<AnyCancellable>()
  
  private let service: NetworkService<CakeAPI>
  
  private var page = 0
  
  
  // MARK: - Initializers
  
  init(service: NetworkService<CakeAPI>) {
    self.service = service
    
    self.input = Input()
    self.output = Output()
    bind(input, output)
  }
  
  
  // MARK: - Binds
  
  private func bind(_ input: Input, _ output: Output) {
    bindItemSelection(input, output)
  }
  
  private func bindItemSelection(_ input: Input, _ output: Output) {
    input
      .didSelectItem
      .sink { indexPath in
        let selectedFeed = output.feedData.value[indexPath.row]
        output.showFeedDetail.send(selectedFeed)
      }
      .store(in: &cancellableBag)
  }
  
  
  // MARK: - Public
  
  public func fetchFeedData() {
    output.isLoading.send(true)
    page += 1
    
    service
      .request(.fetchFeed(page: 1), type: FeedResponse.self)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        switch completion {
        case .finished:
          self?.output.isLoading.send(false)
          
        case .failure(let error):
          print(error)
        }
      } receiveValue: { [weak self] feeds in
        self?.output.feedData.value.append(contentsOf: feeds)
      }
      .store(in: &cancellableBag)
  }
}
