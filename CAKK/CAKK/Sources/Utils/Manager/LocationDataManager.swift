//
//  LocationDataManager.swift
//  CAKK
//
//  Created by Mason Kim on 2023/06/06.
//

import CoreLocation

import Combine

final class LocationDataManager: NSObject {
  
  // MARK: - Properties
  
  private let locationManager = CLLocationManager()
  
  // 권한 상태
  var authorizationStatus: CLAuthorizationStatus {
    locationManager.authorizationStatus
  }
  
  // 사용자의 현재 위치
  var currentCoordinates: Coordinates? {
    guard let location = locationManager.location else { return nil }
    
    return Coordinates(
      latitude: location.coordinate.latitude,
      longitude: location.coordinate.longitude
    )
  }
  
  // 권한 변경 publisher
  let didChangeAuthorization = PassthroughSubject<CLAuthorizationStatus, Never>()
  
  // MARK: - Singleton
  
  static let shared = LocationDataManager()
  
  private override init() {
    super.init()
    locationManager.delegate = self
  }
}

// MARK: - CLLocationManagerDelegate

extension LocationDataManager: CLLocationManagerDelegate {
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if case .notDetermined = manager.authorizationStatus {
      locationManager.requestWhenInUseAuthorization()
      return
    }
    
    didChangeAuthorization.send(manager.authorizationStatus)
  }
}
