//
//  CakkMapView.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/18.
//

import Combine

import NMapsMap

final class CakkMapView: NMFNaverMapView {
  
  private enum MarkerImage {
    static let pin = NMFOverlayImage(image: R.image.map_pin() ?? .checkmark)
    static let selectedPin = NMFOverlayImage(image: R.image.map_pin_selected() ?? .checkmark)
  }
  
  // MARK: - Properties
  
  private var cancellableBag = Set<AnyCancellable>()
  private var markers: [NMFMarker] = []
  private var selectedMarker: NMFMarker? // 마지막으로 선택된 마커
  
  // 마커 선택, 해제 시의 동작 closure 바인딩
  var didTappedMarker: ((CakeShop) -> Void)?
  var didUnselectMarker: (() -> Void)?
  
  // MARK: - LifeCycle
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupMapView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public
  
  public func bind(to viewModel: CakeShopListViewModel) {
    viewModel.output.cakeShops
      .sink { [weak self] cakeShops in
        guard let self = self else { return }
        self.updateMarkers(with: cakeShops)
      }
      .store(in: &cancellableBag)
    
    viewModel.output.presentCakeShopDetail
      .sink { [weak self] cakeShop in
        guard let self = self else { return }
        self.selectMarker(of: cakeShop)
      }
      .store(in: &cancellableBag)
  }
  
  public func unselectMarker() {
    selectedMarker?.iconImage = MarkerImage.pin
    selectedMarker = nil
  }
  
  public func moveCamera(_ position: NMGLatLng, zoomLevel: Double?) {
    if let zoomLevel = zoomLevel {
      mapView.zoomLevel = zoomLevel
    }
    
    let cameraUpdate = NMFCameraUpdate(scrollTo: position)
    cameraUpdate.animation = .easeIn
    mapView.moveCamera(cameraUpdate)
  }
  
  public func moveCameraToCurrentPosition() {
    let location = mapView.locationOverlay.location
    moveCamera(location, zoomLevel: nil)
  }
  
  // MARK: - Private
  
  private func setupMapView() {
    mapView.touchDelegate = self
    showZoomControls = false
    mapView.logoAlign = .leftTop
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
    setupMarkerTouchHandler(marker, position: position, cakeShop: cakeShop)
    return marker
  }
  
  // 마커 선택 시의 액션 (카메라 시점 이동... 등) 등록
  private func setupMarkerTouchHandler(_ marker: NMFMarker, position: NMGLatLng, cakeShop: CakeShop) {
    marker.touchHandler = { [weak self] _ in
      guard let self else { return false }
      
      self.selectMarker(marker)
      self.didTappedMarker?(cakeShop)
      
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
    didUnselectMarker?()
  }
}
