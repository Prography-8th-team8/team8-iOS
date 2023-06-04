//
//  RegionModel.swift
//  CAKK
//
//  Created by 이승기 on 2023/05/06.
//

import UIKit

struct DistrictSection: Hashable {
  enum section: Int, CaseIterable {
    case section1, section2, section3, section4, section5, section6, section7, section8
  }
  
  var count: Int
  var color: UIColor
  var borderColor: UIColor
  var districts: [District]
  var sectionName: String {
    districts.map { $0.koreanName }.joined(separator: ", ")
  }
}

extension DistrictSection.section {
  func value() -> DistrictSection {
    switch self {
    case .section1:
      return .init(
        count: 43,
        color: UIColor(hex: 0xE9EDFF),
        borderColor: UIColor(hex: 0xD5D9E9),
        districts: [.dobong, .gangbuk, .nowon])
    case .section2:
      return .init(
        count: 45,
        color: UIColor(hex: 0xFCECEC),
        borderColor: UIColor(hex: 0xE6D8D8),
        districts: [.dongdaemun, .jungnang, .seongdong, .gwangjin])
    case .section3:
      return .init(
        count: 77,
        color: UIColor(hex: 0xFFE7F5),
        borderColor: UIColor(hex: 0xE9D3E0),
        districts: [.eunpyeong, .mapo, .seodaemun])
    case .section4:
      return .init(
        count: 20,
        color: UIColor(hex: 0xFFF8DB),
        borderColor: UIColor(hex: 0xE9E3C8),
        districts: [.jongno, .jung, .yongsan])
    case .section5:
      return .init(
        count: 34,
        color: UIColor(hex: 0xF6C3C3),
        borderColor: UIColor(hex: 0xE1B3B3),
        districts: [.gangseo, .yangcheon, .yeongdeungpo, .guro])
    case .section6:
      return .init(
        count: 28,
        color: UIColor(hex: 0xD3DAFF),
        borderColor: UIColor(hex: 0xC1C8E9),
        districts: [.dongjak, .gwanak, .geumcheon])
    case .section7:
      return .init(
        count: 48,
        color: UIColor(hex: 0xFFF5CA),
        borderColor: UIColor(hex: 0xE9E0B9),
        districts: [.seocho, .gangnam])
    case .section8:
      return .init(
        count: 48,
        color: UIColor(hex: 0xFFCEEB),
        borderColor: UIColor(hex: 0xE9BDD7),
        districts: [.gangdong, .songpa])
    }
  }
}
