//
//  CoordinatesUserDefaults.swift
//  CAKK
//
//  Created by 이승기 on 2023/06/04.
//

import Combine

class CoordinatesUserDefaults {
  
  // MARK: - Properties
  
  static let shared = CoordinatesUserDefaults()
  
  public var lastCoordinatesPublisher = PassthroughSubject<Coordinates, Never>()
  
  @UserDefault(key: "coordinte.latitude", defaultValue: 0)
  private(set) var latitude: Double
  
  @UserDefault(key: "coordinate.longitude", defaultValue: 0)
  private(set) var longitude: Double
  
  
  // MARK: - Initialization
  
  private init() { }
  
  
  // MARK: - Methods
  
  public func update(coordinates: Coordinates) {
    // update userDefaults
    latitude = coordinates.latitude
    longitude = coordinates.longitude
    
    // notify
    lastCoordinatesPublisher.send(coordinates)
  }
}
