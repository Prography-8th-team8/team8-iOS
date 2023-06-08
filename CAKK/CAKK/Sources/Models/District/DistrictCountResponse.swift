//
//  DistrictCountResponse.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/07.
//

import Foundation

typealias DistrictCountResponse = [DistrictCount]

struct DistrictCount: Decodable {
  let district: District
  let count: Int
}
