//
//  CakeShopListViewModel.swift
//  CAKK
//
//  Created by 이승기 on 2023/05/16.
//

import UIKit
import Combine

class CakeShopListViewModel {
  
  // MARK: - Properties
  
  struct Input {
    var selectCakeShop = PassthroughSubject<IndexPath, Never>()
  }
  
  struct Output {
    var cakeShops = CurrentValueSubject<[CakeShop], Never>([])
    var presentCakeShopDetail = PassthroughSubject<CakeShop, Never>()
    var isLoading = CurrentValueSubject<Bool, Never>(false)
    var hasNoData = CurrentValueSubject<Bool, Never>(false)
  }
  
  private(set) var input: Input!
  private(set) var output: Output!
  private var cancellableBag = Set<AnyCancellable>()
  
  private let districtSection: DistrictSection
  private let service: NetworkService<CakeAPI>
  
  
  // MARK: - LifeCycle
  
  init(districtSection: DistrictSection,
       service: NetworkService<CakeAPI>) {
    self.districtSection = districtSection
    self.service = service
    
    setupInputOutput()
    setupData()
  }
  
  // MARK: - Privates

  private func setupInputOutput() {
    let input = Input()
    let output = Output()
    
    input.selectCakeShop
      .sink { indexPath in
        let cakeShop = output.cakeShops.value[indexPath.row]
        output.presentCakeShopDetail.send(cakeShop)
      }
      .store(in: &cancellableBag)
    
    self.input = input
    self.output = output
  }
  
  private func setupData() {
    fetchCakeShops()
  }
  
  private func fetchCakeShops() {
    Just(Void())
      .map { [weak self] in
        self?.output.hasNoData.send(false)
        self?.output.isLoading.send(true)
      }
      .flatMap { [unowned self] (_) -> AnyPublisher<[CakeShop], Error> in
        self.service.request(
          .fetchCakeShopList(districts: self.districtSection.districts),
          type: CakeShopResponse.self)
      }
      .sink { [weak self] error in
        print(error)
        self?.output.isLoading.send(false)
      } receiveValue: { [weak self] cakeShops in
        if cakeShops.isEmpty {
          self?.output.hasNoData.send(true)
        } else {
          self?.output.hasNoData.send(false)
        }

        self?.output.cakeShops.send(cakeShops)
      }
      .store(in: &cancellableBag)
  }
}
