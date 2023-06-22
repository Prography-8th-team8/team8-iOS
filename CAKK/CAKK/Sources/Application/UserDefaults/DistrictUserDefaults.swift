//
//  DistrictUserDefaults.swift
//  CAKK
//
//  Created by 이승기 on 2023/06/04.
//

import Combine

class DistrictUserDefaults {
  
  // MARK: - Properties
  
  static let shared = DistrictUserDefaults()
  
  public var selectedDistrictSectionPublisher = PassthroughSubject<DistrictSection.Section, Never>()
  
  @UserDefault(key: "district.section.selected", defaultValue: 0)
  private(set) var selectedDistrictSection: Int?
  
  
  // MARK: - LifeCycle
  
  private init() { }
  
  
  // MARK: - Methods
  
  public func updateSelected(districtSection: DistrictSection.Section) {
    // update userDefaults
    selectedDistrictSection = districtSection.rawValue
    // notify
    selectedDistrictSectionPublisher.send(districtSection)
  }
}
