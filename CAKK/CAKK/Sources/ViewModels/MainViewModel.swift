//
//  MainViewModel.swift
//  CAKK
//
//  Created by 이승기 on 2023/06/01.
//

import UIKit
import Combine

class MainViewModel: ViewModelType {
  
  // MARK: - Properties
  
  struct Input {
    
  }
  
  struct Output {
    var cakeShops = CurrentValueSubject<[CakeShop], Never>([])
    var averageCoordinates = PassthroughSubject<(lat: Double, lon: Double), Never>()
  }
  
  private(set) var input: Input!
  private(set) var output: Output!
  private var cancellableBag = Set<AnyCancellable>()
  
  
  private var districts: [District]
  private let service: NetworkService<CakeAPI>
  
  
  // MARK: - LifeCycle
  
  init(districts: [District], service: NetworkService<CakeAPI>) {
    self.districts = districts
    self.service = service
    
    setupInputOutput()
  }
  
  
  // MARK: - Private
  
  private func setupInputOutput() {
    let input = Input()
    let output = Output()
    
    let service = service
    let districts = districts
    
    Just(Void())
      .subscribe(on: DispatchQueue.global())
      .receive(on: DispatchQueue.main)
      .flatMap { service.request(.fetchCakeShopList(districts: districts), type: CakeShopResponse.self) }
      .sink { error in
        print(error)
      } receiveValue: { cakeShops in
        // TODO: - MVP 에서는 그냥 모두 불러와서 필터링 하는 방식으로 사용중. 서버 들어오면 필터 로직은 서버가 가지기 때문에 삭제 필요함.
        let filteredCakeShops = cakeShops.filter { districts.contains($0.district) }
        let lat = filteredCakeShops.map { $0.latitude }.reduce(0, +) / Double(filteredCakeShops.count)
        let lon = filteredCakeShops.map { $0.longitude }.reduce(0, +) / Double(filteredCakeShops.count)
        
        output.cakeShops.send(filteredCakeShops)
        output.averageCoordinates.send((lat, lon))
      }
      .store(in: &cancellableBag)
    
    self.input = input
    self.output = output
  }
}
