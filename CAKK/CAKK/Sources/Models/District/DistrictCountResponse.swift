//
//  DistrictCountResponse.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/07.
//

import Foundation

struct DistrictCount: Decodable {
  let district: District
  let count: Int
}

typealias DistrictCountResponse = [DistrictCount]
