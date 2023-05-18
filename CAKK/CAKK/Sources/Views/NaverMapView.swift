//
//  NaverMapView.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/18.
//

import Combine

import NMapsMap

final class NaverMapView: NMFNaverMapView {
  
  private enum MarkerImage {
    static let pin = NMFOverlayImage(image: R.image.map_pin() ?? .checkmark)
    static let selectedPin = NMFOverlayImage(image: R.image.map_pin_selected() ?? .checkmark)
  }
  
  // MARK: - Properties
  
  private var cancellableBag = Set<AnyCancellable>()
  private var markers: [NMFMarker] = []
  private var selectedMarker: NMFMarker?
  
  var didTappedMarker: ((CakeShop) -> Void)?
  
  // MARK: - LifeCycle
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    showZoomControls = false
    mapView.logoAlign = .rightTop
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public
  
  func bind(to viewModel: CakeShopListViewModel) {
    viewModel.output.cakeShops
      .sink { [weak self] cakeShops in
        guard let self = self else { return }
        self.updateMarkers(with: cakeShops)
      }
      .store(in: &cancellableBag)
  }
  
  // MARK: - Private
  
  private func updateMarkers(with cakeShops: [CakeShop]) {
    clearMarkers()
    
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
  
  private func setupMarkerTouchHandler(_ marker: NMFMarker, position: NMGLatLng, cakeShop: CakeShop) {
    marker.touchHandler = { [weak self] _ in
      let cameraUpdate = NMFCameraUpdate(scrollTo: position)
      cameraUpdate.animation = .easeIn
      self?.mapView.moveCamera(cameraUpdate)
      marker.iconImage = MarkerImage.selectedPin
      
      if marker != self?.selectedMarker {
        self?.selectedMarker?.iconImage = MarkerImage.pin
      }
      
      self?.selectedMarker = marker
      self?.didTappedMarker?(cakeShop)
      
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
  
}
