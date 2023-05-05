//
//  RegionModel.swift
//  CAKK
//
//  Created by 이승기 on 2023/05/06.
//

import UIKit

struct RegionModel: Hashable {
  var regionName: String
  var numberOfRegions: Int
  var color: UIColor
}

extension RegionModel {
  static func fakeItems() -> [RegionModel] {
    return [
      .init(regionName: "도봉 강북 성북 노원", numberOfRegions: 43, color: UIColor(hex: 0x2448FF).withAlphaComponent(0.1)),
      .init(regionName: "동대문 중랑 성동 광진", numberOfRegions: 45, color: UIColor(hex: 0xFF857D).withAlphaComponent(0.2)),
      .init(regionName: "은평 마포 서대문", numberOfRegions: 77, color: UIColor(hex: 0xFF5CBE).withAlphaComponent(0.15)),
      .init(regionName: "종로 중구 용산", numberOfRegions: 20, color: UIColor(hex: 0xFEDC4D).withAlphaComponent(0.2)),
      .init(regionName: "강서 양천 영등포 구로", numberOfRegions: 34, color: UIColor(hex: 0xFF857D).withAlphaComponent(0.4)),
      .init(regionName: "동작 관악 금천", numberOfRegions: 28, color: UIColor(hex: 0x2448FF).withAlphaComponent(0.2)),
      .init(regionName: "서초 강남", numberOfRegions: 48, color: UIColor(hex: 0xFEDC4D).withAlphaComponent(0.3)),
      .init(regionName: "강동 송파", numberOfRegions: 48, color: UIColor(hex: 0xFF5CBE).withAlphaComponent(0.3)),
    ]
  }
}
