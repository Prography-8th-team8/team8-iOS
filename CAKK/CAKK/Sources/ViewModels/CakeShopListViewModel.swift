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
    service.request(
      .fetchCakeShopList(districts: districtSection.districts),
      type: CakeShopResponse.self)
    .sink { error in
      print(error)
    } receiveValue: { [weak self] response in
      self?.output.cakeShops
        .send(response.cakeShops)
    }
    .store(in: &cancellableBag)
  }
}
