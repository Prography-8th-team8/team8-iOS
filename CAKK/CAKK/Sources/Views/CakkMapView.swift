//
//  CakkMapView.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/18.
//

import Combine

import NMapsMap

final class CakkMapView: NMFNaverMapView {
  
  
  // MARK: - Constants
  
  private enum MarkerImage {
    static let pin = NMFOverlayImage(image: R.image.pin_cake_black()!)
    static let selectedPin = NMFOverlayImage(image: R.image.pin_cake_pink()!)
  }
  
  // MARK: - Types
  
  typealias ViewModel = MainViewModel
  
  
  // MARK: - Properties
  
  private weak var viewModel: MainViewModel?
  
  private var cancellableBag = Set<AnyCancellable>()
  private var markers: [NMFMarker] = []
  private var selectedMarker: NMFMarker? // 마지막으로 선택된 마커
  
  
  // MARK: - Initialization
  
  init(viewModel: ViewModel) {
    self.viewModel = viewModel
    super.init(frame: .zero)
    
    setupMapView()
    bind(viewModel)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Public
  
  public func unselectMarker() {
    selectedMarker?.iconImage = MarkerImage.pin
    selectedMarker = nil
  }
  
  public func moveCamera(_ position: NMGLatLng, zoomLevel: Double?) {
    if let zoomLevel = zoomLevel {
      mapView.zoomLevel = zoomLevel
    }
    
    let cameraUpdate = NMFCameraUpdate(scrollTo: position)
    cameraUpdate.animationDuration = 0.6
    cameraUpdate.animation = .easeOut
    mapView.moveCamera(cameraUpdate)
  }
  
  public func moveCameraToCurrentPosition() {
    guard let coordinates = LocationDataManager.shared.currentCoordinates else { return }
    
    let location = NMGLatLng(lat: coordinates.latitude, lng: coordinates.longitude)
    moveCamera(location, zoomLevel: nil)
  }
  
  
  // MARK: - Private
  
  private func bind(_ viewModel: ViewModel?) {
    guard let viewModel else { return }
    
    viewModel.output.cakeShops
      .sink { [weak self] cakeShops in
        guard let self = self else { return }
        self.updateMarkers(with: cakeShops)
      }
      .store(in: &cancellableBag)
    
    viewModel.output
      .selectedCakeShop
      .sink { [weak self] selectedCakeShop in
        if let selectedCakeShop {
          self?.selectMarker(of: selectedCakeShop)
        }
      }
      .store(in: &cancellableBag)
  }
  
  private func setupMapView() {
    mapView.touchDelegate = self
    showZoomControls = false
    mapView.logoAlign = .rightBottom
    mapView.positionMode = .normal
  }
  
  private func updateMarkers(with cakeShops: [CakeShop]) {
    clearMarkers()
    
    // 마커를 등록한 후, 차후 clear 시 해제를 위해 현재 선택된 마커들을 담아놓음
    markers = cakeShops.map {
      makeMarker(with: $0)
    }
  }
  
  private func makeMarker(with cakeShop: CakeShop) -> NMFMarker {
    let position = NMGLatLng(lat: cakeShop.latitude, lng: cakeShop.longitude)
    let marker = NMFMarker(position: position)
    marker.mapView = mapView
    marker.iconImage = MarkerImage.pin
    marker.userInfo = [cakeShop.id: cakeShop]
    marker.captionText = cakeShop.name
    marker.isHideCollidedCaptions = true
    setupMarkerTouchHandler(marker, position: position, cakeShop: cakeShop)
    return marker
  }
  
  // 마커 선택 시의 액션 (카메라 시점 이동... 등) 등록
  private func setupMarkerTouchHandler(_ marker: NMFMarker, position: NMGLatLng, cakeShop: CakeShop) {
    marker.touchHandler = { [weak self] _ in
      guard let self else { return false }
      
      self.selectMarker(marker)
      self.viewModel?.input.selectCakeShopMarker.send(cakeShop)
      
      return true
    }
  }
  
  private func clearMarkers() {
    markers.forEach {
      $0.mapView = nil
      $0.touchHandler = nil
    }
    markers.removeAll()
    
    selectedMarker = nil
  }
  
  // 등록된 마커들 중, 특정 케이크 샵에 대한 마커 선택
  private func selectMarker(of cakeShop: CakeShop) {
    guard let marker = markers.first(where: { marker in
      marker.position.lat == cakeShop.latitude &&
      marker.position.lng == cakeShop.longitude
    }) else {
      return
    }
    
    selectMarker(marker)
  }
  
  // 특정 마커 선택 시 이미지 변경, 카메라 이동
  private func selectMarker(_ marker: NMFMarker) {
    moveCamera(marker.position, zoomLevel: nil)
    
    marker.iconImage = MarkerImage.selectedPin
    
    if marker != selectedMarker {
      unselectMarker()
    }
    
    selectedMarker = marker
  }
}


// MARK: - NMFMapViewTouchDelegate

extension CakkMapView: NMFMapViewTouchDelegate {
  // 맵뷰 마커가 아닌 다른 영역 선택 시 해당 마커를 해제하기 위함
  func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
    unselectMarker()
    viewModel?.output.selectedCakeShop.send(nil)
  }
}
