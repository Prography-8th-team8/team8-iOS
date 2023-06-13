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
    let searchByMapBounds = PassthroughSubject<NMGLatLngBounds, Never>()
  }
  
  struct Output {
    let cakeShops = PassthroughSubject<[CakeShop], Never>()
    let cameraCoordinates = PassthroughSubject<Coordinates, Never>()
    let showDistrictSelectionView = PassthroughSubject<Void, Never>()
    let loadingCakeShops = CurrentValueSubject<Bool, Never>(false)
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
  
  
  // MARK: - Public
  
  public func setSelectedDistrict() {
    guard DistrictUserDefaults.shared.selectedDistrictSection != nil else {
      output.showDistrictSelectionView.send(Void())
      return
    }
    
    loadMyFinalPosition()
  }
  
  public func loadMyFinalPosition() {
    let latitude = CoordinatesUserDefaults.shared.latitude
    let longitude = CoordinatesUserDefaults.shared.longitude

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
    
    input.cameraMove
      .debounce(for: 1, scheduler: DispatchQueue.main)
      .sink { coordinates in
        CoordinatesUserDefaults.shared.update(coordinates: coordinates)
      }
      .store(in: &cancellableBag)
    
    DistrictUserDefaults.shared
      .selectedDistrictSectionPublisher
      .sink { [weak self] section in
        self?.loadCakeShops(section.value().districts)
      }
      .store(in: &cancellableBag)
    
    input.searchByMapBounds
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
      .map { cakeShops in
        cakeShops.filter { cakeShop in
          latitudeRange.contains(cakeShop.latitude) &&
          longitudeRange.contains(cakeShop.longitude)
        }
      }
      .sink { [weak self] error in
        print(error)
        self?.output.loadingCakeShops.send(false)
      } receiveValue: { [weak self] filteredCakeShops in
        self?.output.cakeShops.send(filteredCakeShops)
        self?.output.loadingCakeShops.send(false)
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
      .sink { error in
        print(error)
      } receiveValue: { [weak self] cakeShops in
        // TODO: - MVP 에서는 그냥 모두 불러와서 필터링 하는 방식으로 사용중. 서버 들어오면 필터 로직은 서버가 가지기 때문에 삭제 필요함.
        let filteredCakeShops = cakeShops.filter { districts.contains($0.district) }
        let lat = filteredCakeShops.map { $0.latitude }.reduce(0, +) / Double(filteredCakeShops.count)
        let lon = filteredCakeShops.map { $0.longitude }.reduce(0, +) / Double(filteredCakeShops.count)
        
        self?.output.loadingCakeShops.send(false)
        self?.output.cakeShops.send(filteredCakeShops)
        self?.output.cameraCoordinates.send(Coordinates(latitude: lat, longitude: lon))
      }
      .store(in: &cancellableBag)
  }
}
