//
//  MainViewModel.swift
//  CAKK
//
//  Created by 이승기 on 2023/06/01.
//

import UIKit
import Combine

import NMapsGeometry

class MainViewModel: ViewModelType {
  
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
        self?.loadCakeShops(section.value().districts)
      }
      .store(in: &cancellableBag)
    
    FilteredCategoryUserDefault.shared
      .filteredCategoryPublisher
      .sink { categories in
        output.filteredCategory.send(categories)
        /// 마지막 바운드로 필터된 상태로 요청
        input.searchByMapBounds.send(input.searchByMapBounds.value)
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
    let latitudeRange = (bounds.southWestLat...bounds.northEastLat)
    let longitudeRange = (bounds.southWestLng...bounds.northEastLng)
    
    output.loadingCakeShops.send(true)
    
    service
      .request(.fetchCakeShopList(districts: districts), type: CakeShopResponse.self)
      .subscribe(on: DispatchQueue.global())
      .receive(on: DispatchQueue.main)
      .map { [weak self] cakeShops in
        cakeShops.filter { cakeShop in
          let isContainingFilteredCategory = self?.output.filteredCategory.value.contains { category in
            cakeShop.cakeCategories.contains(category)
          } ?? false
          
          return latitudeRange.contains(cakeShop.latitude) &&
          longitudeRange.contains(cakeShop.longitude) &&
          isContainingFilteredCategory
        }
      }
      .sink { [weak self] completion in
        switch completion {
        case .finished:
          self?.output.loadingCakeShops.send(false)
        case .failure(let error):
          print(error)
        }
      } receiveValue: { [weak self] filteredCakeShops in
        self?.output.cakeShops.send(filteredCakeShops)
      }
      .store(in: &cancellableBag)

  }
  
  private func loadCakeShops(_ districts: [District]) {
    let service = service
    let districts = districts
    
    output.loadingCakeShops.send(true)
    
    Just(Void())
      .subscribe(on: DispatchQueue.global())
      .receive(on: DispatchQueue.main)
      .flatMap { service.request(.fetchCakeShopList(districts: districts), type: CakeShopResponse.self) }
      .sink { [weak self] completion in
        switch completion {
        case .finished:
          self?.output.loadingCakeShops.send(false)
        case .failure(let error):
          print(error)
        }
      } receiveValue: { [weak self] cakeShops in
        let filteredCakeShops = cakeShops
          .filter { cakeShop in
            let isContainingFilteredCategory = self?.output.filteredCategory.value.contains { category in
              cakeShop.cakeCategories.contains(category)
            } ?? false
            
            return districts.contains(cakeShop.district) && isContainingFilteredCategory
          }
        let lat = filteredCakeShops.map { $0.latitude }.reduce(0, +) / Double(filteredCakeShops.count)
        let lon = filteredCakeShops.map { $0.longitude }.reduce(0, +) / Double(filteredCakeShops.count)
        
        self?.output.cakeShops.send(filteredCakeShops)
        self?.output.cameraCoordinates.send(Coordinates(latitude: lat, longitude: lon))
      }
      .store(in: &cancellableBag)
  }
}
