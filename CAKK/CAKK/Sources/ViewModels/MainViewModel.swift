//
//  MainViewModel.swift
//  CAKK
//
//  Created by 이승기 on 2023/06/01.
//

import UIKit

import Combine
import NMapsGeometry

final class MainViewModel {
  
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
  
  let input: Input
  let output: Output
  private var cancellableBag = Set<AnyCancellable>()
  
  private let service: NetworkService<CakeAPI>
  private let storage: RealmStorageProtocol
  
  
  // MARK: - Initialization
  
  init(service: NetworkService<CakeAPI>, storage: RealmStorageProtocol) {
    self.service = service
    self.storage = storage
    
    self.input = Input()
    self.output = Output()
    
    bind(input, output)
  }
  
  // MARK: - Binds
  
  private func bind(_ input: Input, _ output: Output) {
    bindDistrictUserDefault(input, output)
    bindFilterCategoryUserDefault(input, output)
    bindCameraMove(input, output)
    bindSelectCakeShop(input, output)
    bindSelectCakeShopMarker(input, output)
    bindSearchByBounds(input, output)
  }
  
  private func bindDistrictUserDefault(_ input: Input, _ output: Output) {
    DistrictUserDefault.shared
      .selectedDistrictSectionPublisher
      .sink { [weak self] section in
        self?.loadCakeShops(by: section.value().districts)
      }
      .store(in: &cancellableBag)
  }
  
  private func bindFilterCategoryUserDefault(_ input: Input, _ output: Output) {
    FilteredCategoryUserDefault.shared
      .filteredCategoryPublisher
      .sink { [weak self] categories in
        output.filteredCategory.send(categories)
        self?.loadCakeShops(by: input.searchByMapBounds.value)
      }
      .store(in: &cancellableBag)
  }
  
  private func bindCameraMove(_ input: Input, _ output: Output) {
    input.cameraMove
      .debounce(for: 1, scheduler: DispatchQueue.main)
      .sink { coordinates in
        CoordinatesUserDefault.shared.update(coordinates: coordinates)
      }
      .store(in: &cancellableBag)
  }
  
  private func bindSelectCakeShop(_ input: Input, _ output: Output) {
    input.selectCakeShop
      .map { output.cakeShops.value[safe: $0.row] }
      .sink { cakeShop in
        output.selectedCakeShop.send(cakeShop)
      }
      .store(in: &cancellableBag)
  }
  
  private func bindSelectCakeShopMarker(_ input: Input, _ output: Output) {
    input.selectCakeShopMarker
      .sink { cakeShop in
        output.selectedCakeShop.send(cakeShop)
      }
      .store(in: &cancellableBag)
  }
  
  private func bindSearchByBounds(_ input: Input, _ output: Output) {
    input.searchByMapBounds
      .dropFirst()
      .sink { [weak self] bounds in
        self?.loadCakeShops(by: bounds)
      }
      .store(in: &cancellableBag)
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
  
  private func loadCakeShops(by bounds: NMGLatLngBounds) {
    let service = service
    // 선택된 카테고리가 없으면 모든 카테고리를 기준으로 검색
    let categories = FilteredCategoryUserDefault.shared.categories.isEmpty ? CakeCategory.allCases : FilteredCategoryUserDefault.shared.categories
    
    output.loadingCakeShops.send(true)
    output.cakeShops.value.removeAll()
    
    let pages = 1...6
    pages.publisher
      .map { Int($0) }
      .flatMap { page -> AnyPublisher<[CakeShop], Error> in
        service.request(.fetchCakeShopsByBounds(bounds, categories: categories, page: page), type: CakeShopResponse.self)
      }
      .receive(on: DispatchQueue.main)
      .collect()
      .map { $0.reduce([], +) }
      .sink { [weak self] _ in
        self?.output.loadingCakeShops.send(false)
      } receiveValue: { [weak self] cakeShops in
        let uniqueCakeShops = Array(Set(cakeShops))
        self?.output.cakeShops.send(uniqueCakeShops)
      }
      .store(in: &cancellableBag)
  }
  
  private func loadCakeShops(by districts: [District]) {
    let service = service
    // 선택된 카테고리가 없으면 모든 카테고리를 기준으로 검색
    let categories = FilteredCategoryUserDefault.shared.categories.isEmpty ? CakeCategory.allCases : FilteredCategoryUserDefault.shared.categories
    
    output.loadingCakeShops.send(true)
    output.cakeShops.value.removeAll()
    
    let pages = 1...6
    pages.publisher
      .map { Int($0) }
      .flatMap { page -> AnyPublisher<[CakeShop], Error> in
        service.request(.fetchCakeShopsByDistricts(districts, categories: categories, page: page), type: CakeShopResponse.self)
      }
      .receive(on: DispatchQueue.main)
      .collect()
      .map { $0.reduce([], +) }
      .sink { [weak self] _ in
        self?.output.loadingCakeShops.send(false)
      } receiveValue: { [weak self] cakeShops in
        let uniqueCakeShops = Array(Set(cakeShops))
        self?.output.cakeShops.send(uniqueCakeShops)
        
        /// 모든 케이크샵들의 중간 지점으로 카메라 이동
        let avgLat = cakeShops.map { $0.latitude }.reduce(0, +) / Double(cakeShops.count)
        let avgLng = cakeShops.map { $0.longitude }.reduce(0, +) / Double(cakeShops.count)
        self?.output.cameraCoordinates.send(.init(latitude: avgLat, longitude: avgLng))
      }
      .store(in: &cancellableBag)
  }
}
