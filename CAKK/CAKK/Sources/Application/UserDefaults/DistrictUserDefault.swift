//
//  DistrictUserDefault.swift
//  CAKK
//
//  Created by 이승기 on 2023/06/04.
//

import Combine

class DistrictUserDefault {
  
  // MARK: - Properties
  
  static let key = "district.section.selected"
  static let shared = DistrictUserDefault()
  
  public var selectedDistrictSectionPublisher = PassthroughSubject<DistrictSection.Section, Never>()
  
  @UserDefault(key: DistrictUserDefault.key, defaultValue: 0)
  private(set) var selectedDistrictSection: Int?
  
  
  // MARK: - Initialization
  
  private init() { }
  
  
  // MARK: - Methods
  
  public func updateSelected(districtSection: DistrictSection.Section) {
    // update userDefaults
    selectedDistrictSection = districtSection.rawValue
    // notify
    selectedDistrictSectionPublisher.send(districtSection)
  }
}
