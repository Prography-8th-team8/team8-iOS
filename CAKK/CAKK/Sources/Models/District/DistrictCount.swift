//
//  DistrictCount.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/07.
//

import Foundation

struct DistrictCount: Decodable {
  let districtCounts: [District: Int]
  
  enum CodingKeys: String, CodingKey {
    case districtCounts = "district"
  }
}
