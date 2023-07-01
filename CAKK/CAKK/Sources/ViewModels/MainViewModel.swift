//
//  MainViewModel.swift
//  CAKK
//
//  Created by 이승기 on 2023/06/01.
//

import UIKit

import Combine
import NMapsGeometry

final class MainViewModel: ViewModelType {
  
  // MARK: - Properties
  
  struct Input {
    let cameraMove = PassthroughSubject<Coordinates, Never>()
    let searchByMapBounds = CurrentValueSubject<NMGLatLngBounds, Never>(.init())
    let selectCakeShop = PassthroughSubject<IndexPath, Never>()
    let selectCakeShopMarker = PassthroughSubject<CakeShop, Never>()
  }
  
  struct Output {
    let cakeShops = CurrentValueSubject<[CakeShop], Never>([])
    let cameraCoordinates = PassthroughSubject<Coordinates, Never>()
    let showDistrictSelectionView = PassthroughSubject<Void, Never>()
    let loadingCakeShops = CurrentValueSubject<Bool, Never>(false)
    let selectedCakeShop = PassthroughSubject<CakeShop?, Never>()
    let filteredCategory = CurrentValueSubject<[CakeCategory], Never>(FilteredCategoryUserDefault.shared.categories)
  }
  
  private(set) var input: Input!
  private(set) var output: Output!
  private var cancellableBag = Set<AnyCancellable>()
  
  
  private var districts: [District]
  private let service: NetworkService<CakeAPI>
  
  
  // MARK: - Initialization
  
  init(districts: [District], service: NetworkService<CakeAPI>) {
    self.districts = districts
    self.service = service
    
    setupInputOutput()
  }
  
  
  // MARK: - Public
  
  public func setSelectedDistrict() {
    guard DistrictUserDefault.shared.selectedDistrictSection != nil else {
      output.showDistrictSelectionView.send(Void())
      return
    }
    
    loadMyFinalPosition()
  }
  
  public func loadMyFinalPosition() {
    let latitude = CoordinatesUserDefault.shared.latitude
    let longitude = CoordinatesUserDefault.shared.longitude

    // 저장된 위,경도가 없을 시 사용자의 현재 위치로 카메라 이동
    guard latitude != 0, longitude != 0 else {
      if let userCoordinates = LocationDataManager.shared.currentCoordinates {
        output.cameraCoordinates.send(userCoordinates)
      }
      return
    }
    
    let lastCoordinates = Coordinates.init(latitude: latitude, longitude: longitude)
    output.cameraCoordinates.send(lastCoordinates)
  }
  
  
  // MARK: - Private
  
  private func setupInputOutput() {
    let input = Input()
    let output = Output()
    
    DistrictUserDefault.shared
      .selectedDistrictSectionPublisher
      .sink { [weak self] section in
        self?.loadCakeShops(by: section.value().districts)
      }
      .store(in: &cancellableBag)
    
    FilteredCategoryUserDefault.shared
      .filteredCategoryPublisher
      .sink { [weak self] categories in
        output.filteredCategory.send(categories)
        self?.loadCakeShops(by: input.searchByMapBounds.value)
      }
      .store(in: &cancellableBag)
    
    input.cameraMove
      .debounce(for: 1, scheduler: DispatchQueue.main)
      .sink { coordinates in
        CoordinatesUserDefault.shared.update(coordinates: coordinates)
      }
      .store(in: &cancellableBag)
    
    input.selectCakeShop
      .map { output.cakeShops.value[safe: $0.row] }
      .sink { cakeShop in
        output.selectedCakeShop.send(cakeShop)
      }
      .store(in: &cancellableBag)
    
    input.selectCakeShopMarker
      .sink { cakeShop in
        output.selectedCakeShop.send(cakeShop)
      }
      .store(in: &cancellableBag)
    
    input.searchByMapBounds
      .dropFirst()
      .sink { [weak self] bounds in
        self?.loadCakeShops(by: bounds)
      }
      .store(in: &cancellableBag)
    
    self.input = input
    self.output = output
  }
  
  private func loadCakeShops(by bounds: NMGLatLngBounds) {
    output.loadingCakeShops.send(true)
    
    service
      .request(.fetchCakeShopsByBounds(bounds, categories: FilteredCategoryUserDefault.shared.categories), type: CakeShopResponse.self)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        switch completion {
        case .finished:
          self?.output.loadingCakeShops.send(false)
        case .failure(let error):
          print(error)
        }
      } receiveValue: { [weak self] cakeShops in
        self?.output.cakeShops.send(cakeShops)
      }
      .store(in: &cancellableBag)
  }
  
  private func loadCakeShops(by districts: [District]) {
    output.loadingCakeShops.send(true)
  
    service.request(.fetchCakeShopsByDistricts(districts, categories: FilteredCategoryUserDefault.shared.categories), type: CakeShopResponse.self)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        switch completion {
        case .finished:
          self?.output.loadingCakeShops.send(false)
        case .failure(let error):
          print(error)
        }
      } receiveValue: { [weak self] cakeShops in
        let avgLat = cakeShops.map { $0.latitude }.reduce(0, +) / Double(cakeShops.count)
        let avgLng = cakeShops.map { $0.longitude }.reduce(0, +) / Double(cakeShops.count)
        
        self?.output.cakeShops.send(cakeShops)
        self?.output.cameraCoordinates.send(.init(latitude: avgLat, longitude: avgLng))
      }
      .store(in: &cancellableBag)
  }
}
