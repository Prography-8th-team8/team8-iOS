//
//  RegionModel.swift
//  CAKK
//
//  Created by 이승기 on 2023/05/06.
//

import UIKit

struct DistrictSection: Hashable {
  var count: Int
  var color: UIColor
  var districts: [District]
  
  var sectionName: String {
    districts.map { $0.koreanName }.joined(separator: " ")
  }
}

extension DistrictSection {
  static func items() -> [DistrictSection] {
    return [
      .init(
        count: 43, color: UIColor(hex: 0x2448FF).withAlphaComponent(0.1),
        districts: [.dobong, .gangbuk, .nowon]),
      .init(
        count: 45, color: UIColor(hex: 0xFF857D).withAlphaComponent(0.2),
        districts: [.dongdaemun, .jungnang, .seongdong, .gwangjin]),
      .init(
        count: 77, color: UIColor(hex: 0xFF5CBE).withAlphaComponent(0.15),
        districts: [.eunpyeong, .mapo, .seodaemun]),
      .init(
        count: 20, color: UIColor(hex: 0xFEDC4D).withAlphaComponent(0.2),
        districts: [.jongno, .jung, .yongsan]),
      .init(
        count: 34, color: UIColor(hex: 0xFF857D).withAlphaComponent(0.4),
        districts: [.gangseo, .yangcheon, .yeongdeungpo, .guro]),
      .init(
        count: 28, color: UIColor(hex: 0x2448FF).withAlphaComponent(0.2),
        districts: [.dongjak, .gwanak, .geumcheon]),
      .init(
        count: 48, color: UIColor(hex: 0xFEDC4D).withAlphaComponent(0.3),
        districts: [.seocho, .gangnam]),
      .init(
        count: 48, color: UIColor(hex: 0xFF5CBE).withAlphaComponent(0.3),
        districts: [.gangdong, .songpa]),
    ]
  }
}
