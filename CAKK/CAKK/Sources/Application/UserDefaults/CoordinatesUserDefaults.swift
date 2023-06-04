//
//  CoordinatesUserDefaults.swift
//  CAKK
//
//  Created by 이승기 on 2023/06/04.
//

import Combine

class CoordinatesUserDefaults {
  
  // MARK: - Constants
  
  enum Constants {
    static let seoulCoordinates = Coordinates(latitude: 37.541, longitude: 126.986)
  }
  
  // MARK: - Properties
  
  static let shared = CoordinatesUserDefaults()
  
  public var lastCoordinatesPublisher = PassthroughSubject<Coordinates, Never>()
  
  @UserDefault(key: "coordinte.latitude", defaultValue: Constants.seoulCoordinates.latitude)
  private(set) var latitude: Double
  
  @UserDefault(key: "coordinate.longitude", defaultValue: Constants.seoulCoordinates.longitude)
  private(set) var longitude: Double
  
  
  // MARK: - LifeCycle
  
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
